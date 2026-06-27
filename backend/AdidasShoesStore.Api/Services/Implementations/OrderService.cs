using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Ghn;
using AdidasShoesStore.Api.DTOs.Order;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System.Text.RegularExpressions;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private const decimal DiscountAmount = 0m;
        private static readonly string[] AllowedStatuses =
        {
            "PendingPayment",
            "Paid",
            "Processing",
            "Shipping",
            "Delivered",
            "Completed",
            "Failed",
            "Cancelled"
        };

        private static readonly string[] RevenueStatuses =
        {
            "Paid",
            "Processing",
            "Shipping",
            "Delivered",
            "Completed"
        };

        private static readonly string[] AllowedPaymentMethods =
        {
            "COD",
            "VNPAY",
            "PAYPAL",
            "SEPAY"
        };

        private readonly AdidasShoesStoreContext _context;
        private readonly IGhnService _ghnService;
        private readonly GhnSettings _ghnSettings;

        public OrderService(
            AdidasShoesStoreContext context,
            IGhnService ghnService,
            IOptions<GhnSettings> ghnOptions)
        {
            _context = context;
            _ghnService = ghnService;
            _ghnSettings = ghnOptions.Value;
        }

        public async Task<OrderServiceResult<OrderDetailDto>> CreateOrderAsync(
            int userId,
            CreateOrderDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.PaymentMethod))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Payment method is required");
            }

            var paymentMethod = dto.PaymentMethod.Trim().ToUpperInvariant();

            if (paymentMethod == "QR")
            {
                return OrderServiceResult<OrderDetailDto>.Fail(
                    "QR payment is no longer supported. Please use SePay."
                );
            }

            if (!AllowedPaymentMethods.Contains(paymentMethod))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Invalid payment method");
            }

            if (dto.ToDistrictId <= 0 || string.IsNullOrWhiteSpace(dto.ToWardCode))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("GHN delivery district and ward are required");
            }

            var address = await _context.UserAddresses
                .AsNoTracking()
                .FirstOrDefaultAsync(a =>
                    a.AddressId == dto.AddressId &&
                    a.UserId == userId);

            if (address == null)
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Address not found");
            }

            if (string.IsNullOrWhiteSpace(address.AddressLine) ||
                !IsValidPhone(address.Phone))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Invalid delivery address or phone number");
            }

            Cart? cart = null;
            List<(ProductVariant Variant, int Quantity)> orderItems;

            if (dto.BuyNowVariantId.HasValue)
            {
                var quantity = dto.BuyNowQuantity.GetValueOrDefault(1);

                if (quantity <= 0)
                {
                    return OrderServiceResult<OrderDetailDto>.Fail("Quantity must be greater than 0");
                }

                var variant = await _context.ProductVariants
                    .Include(v => v.Product)
                    .FirstOrDefaultAsync(v =>
                        v.VariantId == dto.BuyNowVariantId.Value &&
                        v.IsActive == true);

                if (variant == null)
                {
                    return OrderServiceResult<OrderDetailDto>.Fail("Product variant not found");
                }

                orderItems = new List<(ProductVariant Variant, int Quantity)>
                {
                    (variant, quantity)
                };
            }
            else
            {
                cart = await _context.Carts
                    .Include(c => c.CartItems)
                        .ThenInclude(i => i.Variant)
                            .ThenInclude(v => v.Product)
                    .FirstOrDefaultAsync(c => c.UserId == userId);

                if (cart == null || !cart.CartItems.Any())
                {
                    return OrderServiceResult<OrderDetailDto>.Fail("Cart is empty");
                }

                orderItems = cart.CartItems
                    .Select(item => (item.Variant, item.Quantity))
                    .ToList();
            }

            var shippingFeeResult = await _ghnService.CalculateFeeAsync(
                BuildGhnFeeRequest(dto.ToDistrictId, dto.ToWardCode, orderItems)
            );

            if (!shippingFeeResult.Success || shippingFeeResult.Data == null)
            {
                return OrderServiceResult<OrderDetailDto>.Fail(
                    "Cannot calculate shipping fee. Please check delivery address."
                );
            }

            if (dto.ShippingFee.HasValue &&
                Math.Abs(dto.ShippingFee.Value - shippingFeeResult.Data.ShippingFee) > 1000m)
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Shipping fee is no longer valid. Please recalculate shipping fee.");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                foreach (var item in orderItems)
                {
                    var updatedRows = await _context.Database.ExecuteSqlInterpolatedAsync($@"
                        UPDATE ProductVariants
                        SET StockQuantity = StockQuantity - {item.Quantity}
                        WHERE VariantId = {item.Variant.VariantId}
                            AND ISNULL(StockQuantity, 0) >= {item.Quantity}");

                    if (updatedRows != 1)
                    {
                        var productLabel = $"{item.Variant.Product.ProductName} - Size {item.Variant.Size}, Color {item.Variant.Color}";

                        await transaction.RollbackAsync();

                        return OrderServiceResult<OrderDetailDto>.Fail(
                            $"Insufficient stock for {productLabel}"
                        );
                    }
                }

                var totalAmount = orderItems.Sum(i => i.Variant.Price * i.Quantity);
                var shippingFee = shippingFeeResult.Data.ShippingFee;
                var finalAmount = totalAmount + shippingFee - DiscountAmount;
                var createdAt = DateTime.Now;
                var initialOrderStatus = paymentMethod == "COD"
                    ? "Processing"
                    : "PendingPayment";

                var order = new Order
                {
                    UserId = userId,
                    OrderCode = GenerateOrderCode(),
                    TotalAmount = totalAmount,
                    ShippingFee = shippingFee,
                    DiscountAmount = DiscountAmount,
                    FinalAmount = finalAmount,
                    Status = initialOrderStatus,
                    ShippingAddress = BuildShippingAddress(address, dto),
                    ToDistrictId = dto.ToDistrictId,
                    ToWardCode = dto.ToWardCode.Trim(),
                    ToProvinceName = dto.ToProvinceName?.Trim(),
                    ToDistrictName = dto.ToDistrictName?.Trim(),
                    ToWardName = dto.ToWardName?.Trim(),
                    ReceiverName = address.ReceiverName,
                    ReceiverPhone = address.Phone,
                    Note = dto.Note,
                    CreatedAt = createdAt,
                    Payment = new Payment
                    {
                        PaymentMethod = paymentMethod,
                        Amount = finalAmount,
                        Status = "Pending"
                    }
                };

                foreach (var item in orderItems)
                {
                    order.OrderItems.Add(new OrderItem
                    {
                        VariantId = item.Variant.VariantId,
                        ProductName = item.Variant.Product.ProductName,
                        Size = item.Variant.Size,
                        Color = item.Variant.Color,
                        Quantity = item.Quantity,
                        UnitPrice = item.Variant.Price
                    });
                }

                _context.Orders.Add(order);

                if (cart != null && paymentMethod == "COD")
                {
                    // Online payment orders keep the cart until payment succeeds or fails.
                    // This keeps unpaid order cancellation/failure recoverable without a cart restore flow.
                    _context.CartItems.RemoveRange(cart.CartItems);
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var orderDetail = await GetOrderDetailAsync(userId, order.OrderId);

                return OrderServiceResult<OrderDetailDto>.Ok(orderDetail!);
            }
            catch
            {
                await transaction.RollbackAsync();

                return OrderServiceResult<OrderDetailDto>.Fail("Could not create order");
            }
        }

        public async Task<List<OrderListDto>> GetMyOrdersAsync(int userId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new OrderListDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    TotalAmount = o.TotalAmount,
                    ShippingFee = o.ShippingFee ?? 0m,
                    DiscountAmount = o.DiscountAmount ?? 0m,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    LatestRefundRequestId = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => (int?)r.RefundRequestId)
                        .FirstOrDefault(),
                    LatestRefundRequestAmount = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => (decimal?)r.RequestedAmount)
                        .FirstOrDefault(),
                    LatestRefundRequestReason = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => r.Reason)
                        .FirstOrDefault(),
                    ShipmentStatus = o.Shipment == null ? null : o.Shipment.Status,
                    GhnOrderCode = o.Shipment == null ? null : o.Shipment.GhnOrderCode,
                    TrackingCode = o.Shipment == null ? null : o.Shipment.TrackingCode,
                    ExpectedDeliveryTime = o.Shipment == null ? null : o.Shipment.ExpectedDeliveryTime,
                    CreatedAt = o.CreatedAt,
                    HasReturnRequest = o.ReturnRequests.Any(),
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductId = i.Variant.ProductId,
                        ProductName = i.ProductName,
                        ImageUrl = i.Variant.ImageUrl ?? i.Variant.Product.ProductImages
                            .OrderByDescending(img => img.IsMain == true)
                            .Select(img => img.ImageUrl)
                            .FirstOrDefault(),
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        Subtotal = i.UnitPrice * i.Quantity
                    }).ToList()
                })
                .ToListAsync();
        }

        public async Task<OrderDetailDto?> GetOrderDetailAsync(
            int userId,
            int orderId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId)
                .Select(o => new OrderDetailDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    TotalAmount = o.TotalAmount,
                    ShippingFee = o.ShippingFee ?? 0m,
                    DiscountAmount = o.DiscountAmount ?? 0m,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    CanReview = o.Status == "Completed" &&
                        !o.ReturnRequests.Any(),
                    ShippingAddress = o.ShippingAddress,
                    ToDistrictId = o.ToDistrictId,
                    ToWardCode = o.ToWardCode,
                    ToProvinceName = o.ToProvinceName,
                    ToDistrictName = o.ToDistrictName,
                    ToWardName = o.ToWardName,
                    ReceiverName = o.ReceiverName,
                    ReceiverPhone = o.ReceiverPhone,
                    Note = o.Note,
                    CreatedAt = o.CreatedAt,
                    PaymentId = o.Payment == null ? null : o.Payment.PaymentId,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentAmount = o.Payment == null ? null : o.Payment.Amount,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    ShipmentId = o.Shipment == null ? null : o.Shipment.ShipmentId,
                    ShipmentStatus = o.Shipment == null ? null : o.Shipment.Status,
                    ShippingProvider = o.Shipment == null ? null : o.Shipment.ShippingProvider,
                    TrackingCode = o.Shipment == null ? null : o.Shipment.TrackingCode,
                    GhnOrderCode = o.Shipment == null ? null : o.Shipment.GhnOrderCode,
                    ExpectedDeliveryTime = o.Shipment == null ? null : o.Shipment.ExpectedDeliveryTime,
                    ShippedAt = o.Shipment == null ? null : o.Shipment.ShippedAt,
                    DeliveredAt = o.Shipment == null ? null : o.Shipment.DeliveredAt,
                    LatestRefundRequestId = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => (int?)r.RefundRequestId)
                        .FirstOrDefault(),
                    LatestRefundRequestCode = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => r.RequestCode)
                        .FirstOrDefault(),
                    LatestRefundRequestStatus = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => r.Status)
                        .FirstOrDefault(),
                    LatestRefundRequestAmount = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => (decimal?)r.RequestedAmount)
                        .FirstOrDefault(),
                    LatestRefundRequestReason = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => r.Reason)
                        .FirstOrDefault(),
                    LatestRefundRequestCustomerNote = o.RefundRequests
                        .OrderByDescending(r => r.CreatedAt)
                        .Select(r => r.CustomerNote)
                        .FirstOrDefault(),
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductId = i.Variant.ProductId,
                        ProductName = i.ProductName,
                        ImageUrl = i.Variant.ImageUrl ?? i.Variant.Product.ProductImages
                            .OrderByDescending(img => img.IsMain == true)
                            .Select(img => img.ImageUrl)
                            .FirstOrDefault(),
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        Subtotal = i.UnitPrice * i.Quantity
                    }).ToList()
                })
                .FirstOrDefaultAsync();
        }

        public async Task<OrderServiceResult<OrderDetailDto>> CancelOrderAsync(
            int userId,
            int orderId)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var order = await _context.Orders
                    .Include(o => o.OrderItems)
                        .ThenInclude(i => i.Variant)
                    .Include(o => o.Payment)
                    .FirstOrDefaultAsync(o =>
                        o.OrderId == orderId &&
                        o.UserId == userId);

                if (order == null)
                {
                    await transaction.RollbackAsync();

                    return OrderServiceResult<OrderDetailDto>.Fail(
                        "Order not found",
                        "NotFound"
                    );
                }

                if (order.Status == "Cancelled")
                {
                    await transaction.RollbackAsync();

                    return OrderServiceResult<OrderDetailDto>.Fail("Order is already cancelled");
                }

                if (order.Status == "Shipping" ||
                    order.Status == "Delivered" ||
                    order.Status == "Completed")
                {
                    await transaction.RollbackAsync();

                    return OrderServiceResult<OrderDetailDto>.Fail(
                        "This order is already being shipped. Please contact support for cancellation or refund."
                    );
                }

                var paymentMethod = order.Payment?.PaymentMethod?.Trim().ToUpperInvariant();
                var paymentStatus = order.Payment?.Status?.Trim();
                var isOnlinePaid = order.Payment != null &&
                    AllowedPaymentMethods.Contains(paymentMethod ?? string.Empty) &&
                    string.Equals(paymentStatus, "Success", StringComparison.OrdinalIgnoreCase);
                var isPendingPayment = string.Equals(order.Status, "PendingPayment", StringComparison.OrdinalIgnoreCase);
                var isCodProcessing = string.Equals(order.Status, "Processing", StringComparison.OrdinalIgnoreCase) &&
                    string.Equals(paymentMethod, "COD", StringComparison.OrdinalIgnoreCase) &&
                    !string.Equals(paymentStatus, "Success", StringComparison.OrdinalIgnoreCase);

                if (isOnlinePaid)
                {
                    await transaction.RollbackAsync();

                    return OrderServiceResult<OrderDetailDto>.Fail(
                        "Paid online orders cannot be cancelled directly. Please request cancellation/refund."
                    );
                }

                if (!isPendingPayment && !isCodProcessing)
                {
                    await transaction.RollbackAsync();

                    return OrderServiceResult<OrderDetailDto>.Fail(
                        "Only pending payment or unshipped COD orders can be cancelled"
                    );
                }

                foreach (var item in order.OrderItems)
                {
                    item.Variant.StockQuantity = (item.Variant.StockQuantity ?? 0) + item.Quantity;
                }

                order.Status = "Cancelled";
                if (order.Payment != null &&
                    !string.Equals(order.Payment.Status, "Success", StringComparison.OrdinalIgnoreCase))
                {
                    order.Payment.Status = "Failed";
                }

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var detail = await GetOrderDetailAsync(userId, orderId);

                return OrderServiceResult<OrderDetailDto>.Ok(detail!);
            }
            catch
            {
                await transaction.RollbackAsync();

                return OrderServiceResult<OrderDetailDto>.Fail("Could not cancel order");
            }
        }

        public async Task<OrderServiceResult<OrderDetailDto>> CompleteOrderAsync(
            int userId,
            int orderId)
        {
            var order = await _context.Orders
                .Include(o => o.ReturnRequests)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId);

            if (order == null)
            {
                return OrderServiceResult<OrderDetailDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Status != "Delivered")
            {
                return OrderServiceResult<OrderDetailDto>.Fail(
                    "Only delivered orders can be completed"
                );
            }

            if (order.ReturnRequests.Any())
            {
                return OrderServiceResult<OrderDetailDto>.Fail(
                    "Orders with return/refund requests cannot be completed"
                );
            }

            order.Status = "Completed";

            await _context.SaveChangesAsync();

            var detail = await GetOrderDetailAsync(userId, orderId);

            return OrderServiceResult<OrderDetailDto>.Ok(detail!);
        }

        public async Task<List<AdminOrderListDto>> GetAdminOrdersAsync(
            string? status,
            DateTime? fromDate,
            DateTime? toDate,
            string? keyword)
        {
            var query = _context.Orders
                .AsNoTracking()
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(status))
            {
                query = query.Where(o => o.Status == status);
            }

            if (fromDate.HasValue)
            {
                query = query.Where(o => o.CreatedAt >= fromDate.Value.Date);
            }

            if (toDate.HasValue)
            {
                var exclusiveToDate = toDate.Value.Date.AddDays(1);
                query = query.Where(o => o.CreatedAt < exclusiveToDate);
            }

            if (!string.IsNullOrWhiteSpace(keyword))
            {
                var normalizedKeyword = keyword.Trim();

                query = query.Where(o =>
                    o.OrderCode.Contains(normalizedKeyword) ||
                    o.ReceiverName.Contains(normalizedKeyword) ||
                    o.ReceiverPhone.Contains(normalizedKeyword) ||
                    o.User.FullName.Contains(normalizedKeyword) ||
                    o.User.Email.Contains(normalizedKeyword));
            }

            return await query
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new AdminOrderListDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    CustomerName = o.User.FullName,
                    CustomerEmail = o.User.Email,
                    ReceiverName = o.ReceiverName,
                    ReceiverPhone = o.ReceiverPhone,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    CreatedAt = o.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<AdminOrderDetailDto?> GetAdminOrderDetailAsync(int orderId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o => o.OrderId == orderId)
                .Select(o => new AdminOrderDetailDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    UserId = o.UserId,
                    CustomerName = o.User.FullName,
                    CustomerEmail = o.User.Email,
                    CustomerPhone = o.User.Phone,
                    ReceiverName = o.ReceiverName,
                    ReceiverPhone = o.ReceiverPhone,
                    ShippingAddress = o.ShippingAddress,
                    ToDistrictId = o.ToDistrictId,
                    ToWardCode = o.ToWardCode,
                    ToProvinceName = o.ToProvinceName,
                    ToDistrictName = o.ToDistrictName,
                    ToWardName = o.ToWardName,
                    TotalAmount = o.TotalAmount,
                    ShippingFee = o.ShippingFee ?? 0m,
                    DiscountAmount = o.DiscountAmount ?? 0m,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    Note = o.Note,
                    CreatedAt = o.CreatedAt,
                    PaymentId = o.Payment == null ? null : o.Payment.PaymentId,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentAmount = o.Payment == null ? null : o.Payment.Amount,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    TransactionCode = o.Payment == null ? null : o.Payment.TransactionCode,
                    PaidAt = o.Payment == null ? null : o.Payment.PaidAt,
                    ShipmentId = o.Shipment == null ? null : o.Shipment.ShipmentId,
                    ShipmentStatus = o.Shipment == null ? null : o.Shipment.Status,
                    ShippingProvider = o.Shipment == null ? null : o.Shipment.ShippingProvider,
                    TrackingCode = o.Shipment == null ? null : o.Shipment.TrackingCode,
                    GhnOrderCode = o.Shipment == null ? null : o.Shipment.GhnOrderCode,
                    ExpectedDeliveryTime = o.Shipment == null ? null : o.Shipment.ExpectedDeliveryTime,
                    ShippedAt = o.Shipment == null ? null : o.Shipment.ShippedAt,
                    DeliveredAt = o.Shipment == null ? null : o.Shipment.DeliveredAt,
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductId = i.Variant.ProductId,
                        ProductName = i.ProductName,
                        ImageUrl = i.Variant.ImageUrl ?? i.Variant.Product.ProductImages
                            .OrderByDescending(img => img.IsMain == true)
                            .Select(img => img.ImageUrl)
                            .FirstOrDefault(),
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        Subtotal = i.UnitPrice * i.Quantity
                    }).ToList()
                })
                .FirstOrDefaultAsync();
        }

        public async Task<OrderServiceResult<AdminOrderDetailDto>> UpdateOrderStatusAsync(
            int orderId,
            UpdateOrderStatusDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Status) ||
                !AllowedStatuses.Contains(dto.Status))
            {
                return OrderServiceResult<AdminOrderDetailDto>.Fail("Invalid order status");
            }

            var order = await _context.Orders
                .Include(o => o.Shipment)
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return OrderServiceResult<AdminOrderDetailDto>.Fail("Order not found");
            }

            if (!IsValidAdminOrderTransition(order, dto.Status))
            {
                return OrderServiceResult<AdminOrderDetailDto>.Fail(
                    $"Invalid order status transition from {order.Status} to {dto.Status}"
                );
            }

            order.Status = dto.Status;

            await _context.SaveChangesAsync();

            var detail = await GetAdminOrderDetailAsync(orderId);

            return OrderServiceResult<AdminOrderDetailDto>.Ok(detail!);
        }

        public async Task<RevenueSummaryDto> GetRevenueSummaryAsync()
        {
            var today = DateTime.Today;
            var tomorrow = today.AddDays(1);
            var monthStart = new DateTime(today.Year, today.Month, 1);
            var nextMonthStart = monthStart.AddMonths(1);

            return new RevenueSummaryDto
            {
                TotalOrders = await _context.Orders.CountAsync(),
                PaidOrders = await _context.Orders.CountAsync(o => o.Status == "Paid"),
                CancelledOrders = await _context.Orders.CountAsync(o => o.Status == "Cancelled"),
                TotalRevenue = await _context.Orders
                    .Where(o =>
                        RevenueStatuses.Contains(o.Status) &&
                        o.Payment != null &&
                        o.Payment.Status == "Success")
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m,
                TodayRevenue = await _context.Orders
                    .Where(o =>
                        RevenueStatuses.Contains(o.Status) &&
                        o.Payment != null &&
                        o.Payment.Status == "Success" &&
                        o.CreatedAt >= today &&
                        o.CreatedAt < tomorrow)
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m,
                MonthRevenue = await _context.Orders
                    .Where(o =>
                        RevenueStatuses.Contains(o.Status) &&
                        o.Payment != null &&
                        o.Payment.Status == "Success" &&
                        o.CreatedAt >= monthStart &&
                        o.CreatedAt < nextMonthStart)
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m
            };
        }

        private GhnCalculateFeeRequestDto BuildGhnFeeRequest(
            int toDistrictId,
            string toWardCode,
            List<(ProductVariant Variant, int Quantity)> orderItems)
        {
            return new GhnCalculateFeeRequestDto
            {
                ToDistrictId = toDistrictId,
                ToWardCode = toWardCode.Trim(),
                ServiceTypeId = _ghnSettings.ServiceTypeId,
                InsuranceValue = _ghnSettings.InsuranceValueDefault,
                Items = orderItems.Select(item => new GhnFeeItemDto
                {
                    Quantity = item.Quantity,
                    Weight = _ghnSettings.DefaultWeight,
                    Length = _ghnSettings.DefaultLength,
                    Width = _ghnSettings.DefaultWidth,
                    Height = _ghnSettings.DefaultHeight
                }).ToList()
            };
        }

        private static string BuildShippingAddress(UserAddress address, CreateOrderDto dto)
        {
            var parts = new[]
            {
                address.AddressLine,
                string.IsNullOrWhiteSpace(dto.ToWardName) ? address.Ward : dto.ToWardName,
                string.IsNullOrWhiteSpace(dto.ToDistrictName) ? address.District : dto.ToDistrictName,
                string.IsNullOrWhiteSpace(dto.ToProvinceName) ? address.City : dto.ToProvinceName
            };

            return string.Join(", ", parts.Where(p => !string.IsNullOrWhiteSpace(p)));
        }

        private static bool IsValidPhone(string? phone)
        {
            return !string.IsNullOrWhiteSpace(phone) &&
                   Regex.IsMatch(phone.Trim(), @"^(0|\+84)[0-9]{8,10}$");
        }

        private static string GenerateOrderCode()
        {
            return $"ORD{DateTime.Now:yyyyMMddHHmmssfff}{Guid.NewGuid():N}"[..25];
        }

        private static bool IsValidAdminOrderTransition(Order order, string newStatus)
        {
            if (string.Equals(order.Status, newStatus, StringComparison.Ordinal))
            {
                return true;
            }

            return order.Status switch
            {
                "PendingPayment" => newStatus == "Cancelled",
                "Paid" => newStatus is "Processing" or "Cancelled",
                "Processing" => newStatus == "Cancelled" ||
                    (newStatus == "Shipping" && order.Shipment != null),
                "Delivered" => newStatus == "Completed",
                _ => false
            };
        }
    }
}
