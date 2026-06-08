using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Order;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private const decimal ShippingFee = 30000m;
        private const decimal DiscountAmount = 0m;
        private static readonly string[] AllowedStatuses =
        {
            "PendingPayment",
            "Paid",
            "Processing",
            "Shipping",
            "Delivered",
            "Cancelled"
        };

        private static readonly string[] RevenueStatuses =
        {
            "Paid",
            "Processing",
            "Shipping",
            "Delivered"
        };

        private readonly AdidasShoesStoreContext _context;

        public OrderService(
            AdidasShoesStoreContext context)
        {
            _context = context;
        }

        public async Task<OrderServiceResult<OrderDetailDto>> CreateOrderAsync(
            int userId,
            CreateOrderDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.PaymentMethod))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Payment method is required");
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

            var cart = await _context.Carts
                .Include(c => c.CartItems)
                    .ThenInclude(i => i.Variant)
                        .ThenInclude(v => v.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null || !cart.CartItems.Any())
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Cart is empty");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var totalAmount = cart.CartItems.Sum(i => i.Variant.Price * i.Quantity);
            var finalAmount = totalAmount + ShippingFee - DiscountAmount;
            var createdAt = DateTime.Now;

            var order = new Order
            {
                UserId = userId,
                OrderCode = GenerateOrderCode(),
                TotalAmount = totalAmount,
                ShippingFee = ShippingFee,
                DiscountAmount = DiscountAmount,
                FinalAmount = finalAmount,
                Status = "PendingPayment",
                ShippingAddress = BuildShippingAddress(address),
                ReceiverName = address.ReceiverName,
                ReceiverPhone = address.Phone,
                Note = dto.Note,
                CreatedAt = createdAt,
                Payment = new Payment
                {
                    PaymentMethod = dto.PaymentMethod.Trim(),
                    Amount = finalAmount,
                    Status = "Pending"
                }
            };

            foreach (var item in cart.CartItems)
            {
                order.OrderItems.Add(new OrderItem
                {
                    VariantId = item.VariantId,
                    ProductName = item.Variant.Product.ProductName,
                    Size = item.Variant.Size,
                    Color = item.Variant.Color,
                    Quantity = item.Quantity,
                    UnitPrice = item.Variant.Price
                });
            }

            _context.Orders.Add(order);
            _context.CartItems.RemoveRange(cart.CartItems);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var orderDetail = await GetOrderDetailAsync(userId, order.OrderId);

            return OrderServiceResult<OrderDetailDto>.Ok(orderDetail!);
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
                    CreatedAt = o.CreatedAt
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
                    ShippingAddress = o.ShippingAddress,
                    ReceiverName = o.ReceiverName,
                    ReceiverPhone = o.ReceiverPhone,
                    Note = o.Note,
                    CreatedAt = o.CreatedAt,
                    PaymentId = o.Payment == null ? null : o.Payment.PaymentId,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentAmount = o.Payment == null ? null : o.Payment.Amount,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductName = i.ProductName,
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        Subtotal = i.UnitPrice * i.Quantity
                    }).ToList()
                })
                .FirstOrDefaultAsync();
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
                    UserId = o.UserId,
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
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductName = i.ProductName,
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
                .FirstOrDefaultAsync(o => o.OrderId == orderId);

            if (order == null)
            {
                return OrderServiceResult<AdminOrderDetailDto>.Fail("Order not found");
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
                    .Where(o => RevenueStatuses.Contains(o.Status))
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m,
                TodayRevenue = await _context.Orders
                    .Where(o =>
                        RevenueStatuses.Contains(o.Status) &&
                        o.CreatedAt >= today &&
                        o.CreatedAt < tomorrow)
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m,
                MonthRevenue = await _context.Orders
                    .Where(o =>
                        RevenueStatuses.Contains(o.Status) &&
                        o.CreatedAt >= monthStart &&
                        o.CreatedAt < nextMonthStart)
                    .SumAsync(o => (decimal?)o.FinalAmount) ?? 0m
            };
        }

        private static string BuildShippingAddress(UserAddress address)
        {
            var parts = new[]
            {
                address.AddressLine,
                address.Ward,
                address.District,
                address.City
            };

            return string.Join(", ", parts.Where(p => !string.IsNullOrWhiteSpace(p)));
        }

        private static string GenerateOrderCode()
        {
            return $"ORD{DateTime.Now:yyyyMMddHHmmssfff}{Guid.NewGuid():N}"[..25];
        }
    }
}
