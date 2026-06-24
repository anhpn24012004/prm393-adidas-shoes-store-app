using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Ghn;
using AdidasShoesStore.Api.DTOs.Shipments;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using System.Text.RegularExpressions;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class ShipmentService : IShipmentService
    {
        private static readonly Dictionary<string, string[]> AllowedTransitions = new(StringComparer.Ordinal)
        {
            ["ReadyToPick"] = new[] { "Picking", "Shipped", "Failed" },
            ["Picking"] = new[] { "Shipped", "Failed" },
            ["Pending"] = new[] { "Preparing" },
            ["Preparing"] = new[] { "Shipped" },
            ["Shipped"] = new[] { "InTransit" },
            ["InTransit"] = new[] { "OutForDelivery" },
            ["OutForDelivery"] = new[] { "Delivered", "Failed" },
            ["Failed"] = new[] { "OutForDelivery", "Returned" }
        };

        private readonly AdidasShoesStoreContext _context;
        private readonly IEmailService _emailService;
        private readonly IGhnService _ghnService;
        private readonly GhnSettings _ghnSettings;

        public ShipmentService(
            AdidasShoesStoreContext context,
            IEmailService emailService,
            IGhnService ghnService,
            IOptions<GhnSettings> ghnOptions)
        {
            _context = context;
            _emailService = emailService;
            _ghnService = ghnService;
            _ghnSettings = ghnOptions.Value;
        }

        public async Task<ShipmentDetailDto?> GetUserShipmentAsync(
            int userId,
            int orderId)
        {
            return await _context.Shipments
                .AsNoTracking()
                .Where(s =>
                    s.OrderId == orderId &&
                    s.Order.UserId == userId)
                .Select(MapShipmentDetail())
                .FirstOrDefaultAsync();
        }

        public async Task<ShipmentTrackingDto?> GetUserTrackingAsync(
            int userId,
            int orderId)
        {
            var tracking = await _context.Shipments
                .AsNoTracking()
                .Where(s =>
                    s.OrderId == orderId &&
                    s.Order.UserId == userId)
                .Select(s => new ShipmentTrackingDto
                {
                    OrderId = s.OrderId,
                    OrderCode = s.Order.OrderCode,
                    OrderStatus = s.Order.Status,
                    ShipmentId = s.ShipmentId,
                    ShipmentStatus = s.Status,
                    Carrier = s.ShippingProvider,
                    TrackingNumber = s.TrackingCode,
                    GhnOrderCode = s.GhnOrderCode,
                    RawGhnStatus = s.RawGhnStatus,
                    EstimatedDeliveryDate = s.ExpectedDeliveryTime,
                    ShippedAt = s.ShippedAt,
                    DeliveredAt = s.DeliveredAt,
                    ReceiverName = s.Order.ReceiverName,
                    ReceiverPhone = s.Order.ReceiverPhone,
                    ShippingAddress = s.Order.ShippingAddress
                })
                .FirstOrDefaultAsync();

            if (tracking != null)
            {
                if (!string.IsNullOrWhiteSpace(tracking.GhnOrderCode))
                {
                    var ghnTracking = await _ghnService.GetTrackingAsync(tracking.GhnOrderCode);

                    if (ghnTracking.Success && ghnTracking.Data != null)
                    {
                        tracking.RawGhnStatus = ghnTracking.Data.RawStatus;
                        tracking.ShipmentStatus = ghnTracking.Data.Status ?? tracking.ShipmentStatus;
                        tracking.EstimatedDeliveryDate = ghnTracking.Data.LeadTime ?? tracking.EstimatedDeliveryDate;
                    }
                }

                return tracking;
            }

            var order = await _context.Orders
                .AsNoTracking()
                .Where(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId)
                .FirstOrDefaultAsync();

            if (order == null)
            {
                return null;
            }

            return new ShipmentTrackingDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                OrderStatus = order.Status,
                ShipmentId = 0,
                ShipmentStatus = MapOrderStatusToShipmentStatus(order.Status),
                Carrier = null,
                TrackingNumber = null,
                EstimatedDeliveryDate = null,
                ShippedAt = null,
                DeliveredAt = null,
                ReceiverName = order.ReceiverName,
                ReceiverPhone = order.ReceiverPhone,
                ShippingAddress = order.ShippingAddress
            };
        }

        public async Task<List<AdminShipmentListDto>> GetAdminShipmentsAsync()
        {
            return await _context.Shipments
                .AsNoTracking()
                .OrderByDescending(s => s.ShippedAt)
                .ThenByDescending(s => s.ShipmentId)
                .Select(s => new AdminShipmentListDto
                {
                    ShipmentId = s.ShipmentId,
                    OrderId = s.OrderId,
                    OrderCode = s.Order.OrderCode,
                    UserId = s.Order.UserId,
                    CustomerName = s.Order.User.FullName,
                    ShippingProvider = s.ShippingProvider,
                    TrackingCode = s.TrackingCode,
                    GhnOrderCode = s.GhnOrderCode,
                    ShipmentStatus = s.Status,
                    OrderStatus = s.Order.Status,
                    ShippedAt = s.ShippedAt,
                    DeliveredAt = s.DeliveredAt
                })
                .ToListAsync();
        }

        public async Task<AdminShipmentDetailDto?> GetAdminShipmentAsync(int shipmentId)
        {
            return await _context.Shipments
                .AsNoTracking()
                .Where(s => s.ShipmentId == shipmentId)
                .Select(s => new AdminShipmentDetailDto
                {
                    ShipmentId = s.ShipmentId,
                    OrderId = s.OrderId,
                    OrderCode = s.Order.OrderCode,
                    OrderStatus = s.Order.Status,
                    OrderCreatedAt = s.Order.CreatedAt,
                    UserId = s.Order.UserId,
                    CustomerName = s.Order.User.FullName,
                    CustomerEmail = s.Order.User.Email,
                    CustomerPhone = s.Order.User.Phone,
                    ReceiverName = s.Order.ReceiverName,
                    ReceiverPhone = s.Order.ReceiverPhone,
                    ShippingAddress = s.Order.ShippingAddress,
                    Carrier = s.ShippingProvider,
                    TrackingNumber = s.TrackingCode,
                    GhnOrderCode = s.GhnOrderCode,
                    ShipmentStatus = s.Status,
                    EstimatedDeliveryDate = s.ExpectedDeliveryTime,
                    Note = null,
                    ShippedAt = s.ShippedAt,
                    DeliveredAt = s.DeliveredAt,
                    PaymentMethod = s.Order.Payment == null ? null : s.Order.Payment.PaymentMethod,
                    PaymentStatus = s.Order.Payment == null ? null : s.Order.Payment.Status,
                    TransactionCode = s.Order.Payment == null ? null : s.Order.Payment.TransactionCode,
                    PaidAt = s.Order.Payment == null ? null : s.Order.Payment.PaidAt,
                    TotalAmount = s.Order.TotalAmount,
                    ShippingFee = s.Order.ShippingFee ?? 0m,
                    DiscountAmount = s.Order.DiscountAmount ?? 0m,
                    FinalAmount = s.Order.FinalAmount,
                    OrderItems = s.Order.OrderItems.Select(i => new AdminShipmentOrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductName = i.ProductName,
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice
                    }).ToList()
                })
                .FirstOrDefaultAsync();
        }

        public async Task<ShipmentServiceResult<AdminShipmentDetailDto>> CreateShipmentAsync(
            CreateShipmentDto dto)
        {
            var order = await _context.Orders
                .Include(o => o.Shipment)
                .Include(o => o.Payment)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId);

            if (order == null)
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Shipment != null)
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail("Shipment already exists for this order");
            }

            if (!CanCreateShipment(order))
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Shipment can only be created for ready COD orders or paid online orders"
                );
            }

            if (!IsValidPhone(order.ReceiverPhone) ||
                string.IsNullOrWhiteSpace(order.ShippingAddress) ||
                order.ToDistrictId == null ||
                string.IsNullOrWhiteSpace(order.ToWardCode))
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Order delivery information is not valid for GHN shipment"
                );
            }

            var ghnRequest = BuildGhnCreateOrderRequest(order);
            var ghnResult = await _ghnService.CreateOrderAsync(ghnRequest);

            if (!ghnResult.Success || ghnResult.Data == null)
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Cannot create GHN shipment. Please try again later."
                );
            }

            var shipment = new Shipment
            {
                OrderId = order.OrderId,
                ShippingProvider = "GHN",
                TrackingCode = ghnResult.Data.GhnOrderCode,
                GhnOrderCode = ghnResult.Data.GhnOrderCode,
                ShippingFee = ghnResult.Data.TotalFee > 0 ? ghnResult.Data.TotalFee : order.ShippingFee,
                ExpectedDeliveryTime = ghnResult.Data.ExpectedDeliveryTime,
                RawGhnStatus = ghnResult.Data.Status,
                Status = "ReadyToPick",
                ShippedAt = DateTime.Now
            };

            order.Status = "Shipping";

            _context.Shipments.Add(shipment);
            await _context.SaveChangesAsync();

            var detail = await GetAdminShipmentAsync(shipment.ShipmentId);

            return ShipmentServiceResult<AdminShipmentDetailDto>.Ok(detail!);
        }

        public async Task<ShipmentServiceResult<AdminShipmentDetailDto>> UpdateShipmentStatusAsync(
            int shipmentId,
            UpdateShipmentStatusDto dto)
        {
            var shipment = await _context.Shipments
                .Include(s => s.Order)
                    .ThenInclude(o => o.Payment)
                .Include(s => s.Order)
                    .ThenInclude(o => o.User)
                .Include(s => s.Order)
                    .ThenInclude(o => o.OrderItems)
                .FirstOrDefaultAsync(s => s.ShipmentId == shipmentId);

            if (shipment == null)
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Shipment not found",
                    "NotFound"
                );
            }

            var newStatus = dto.Status?.Trim();

            if (string.IsNullOrWhiteSpace(newStatus))
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail("Shipment status is required");
            }

            var currentStatus = shipment.Status?.Trim();

            if (!IsValidTransition(currentStatus, newStatus))
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    $"Invalid shipment status transition from {currentStatus ?? "Unknown"} to {newStatus}"
                );
            }

            shipment.Status = newStatus;
            var shouldSendCodInvoice = false;

            if (newStatus == "Delivered")
            {
                shipment.DeliveredAt = DateTime.Now;
                shipment.Order.Status = "Delivered";
                shipment.RawGhnStatus = newStatus;

                if (shipment.Order.Payment != null &&
                    string.Equals(shipment.Order.Payment.PaymentMethod, "COD", StringComparison.OrdinalIgnoreCase))
                {
                    shipment.Order.Payment.Status = "Success";
                    shipment.Order.Payment.PaidAt = DateTime.Now;
                    shipment.Order.Payment.TransactionCode = $"COD-{shipment.Order.OrderCode}";
                    shouldSendCodInvoice = true;
                }
            }
            else if (newStatus == "Returned")
            {
                shipment.Order.Status = "Cancelled";
                shipment.RawGhnStatus = newStatus;
            }

            await _context.SaveChangesAsync();

            if (shouldSendCodInvoice)
            {
                try
                {
                    await _emailService.SendInvoiceEmailAsync(shipment.Order);
                }
                catch
                {
                    // Delivery status is already saved; email failure should not rollback it.
                }
            }

            var detail = await GetAdminShipmentAsync(shipmentId);

            return ShipmentServiceResult<AdminShipmentDetailDto>.Ok(detail!);
        }

        public async Task<ShipmentServiceResult<AdminShipmentDetailDto>> UpdateTrackingInfoAsync(
            int shipmentId,
            UpdateTrackingInfoDto dto)
        {
            var shipment = await _context.Shipments
                .FirstOrDefaultAsync(s => s.ShipmentId == shipmentId);

            if (shipment == null)
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Shipment not found",
                    "NotFound"
                );
            }

            shipment.ShippingProvider = string.IsNullOrWhiteSpace(dto.Carrier)
                ? shipment.ShippingProvider
                : dto.Carrier.Trim();
            shipment.TrackingCode = string.IsNullOrWhiteSpace(dto.TrackingNumber)
                ? shipment.TrackingCode
                : dto.TrackingNumber.Trim();

            await _context.SaveChangesAsync();

            var detail = await GetAdminShipmentAsync(shipmentId);

            return ShipmentServiceResult<AdminShipmentDetailDto>.Ok(detail!);
        }

        private static bool IsValidTransition(
            string? currentStatus,
            string newStatus)
        {
            if (string.Equals(currentStatus, newStatus, StringComparison.Ordinal))
            {
                return true;
            }

            if (string.IsNullOrWhiteSpace(currentStatus))
            {
                return false;
            }

            return AllowedTransitions.TryGetValue(currentStatus, out var nextStatuses) &&
                   nextStatuses.Contains(newStatus, StringComparer.Ordinal);
        }

        private static bool CanCreateShipment(Order order)
        {
            if (order.Status == "Cancelled" ||
                order.Status == "Failed" ||
                order.Status == "PendingPayment" ||
                order.Status == "Shipping" ||
                order.Status == "Delivered" ||
                order.Status == "Completed" ||
                order.Payment == null)
            {
                return false;
            }

            var method = order.Payment.PaymentMethod;
            var paymentStatus = order.Payment.Status;

            if (string.Equals(method, "COD", StringComparison.OrdinalIgnoreCase))
            {
                return order.Status == "Processing" &&
                       string.Equals(paymentStatus, "Pending", StringComparison.OrdinalIgnoreCase);
            }

            return (order.Status == "Paid" || order.Status == "Processing") &&
                   string.Equals(paymentStatus, "Success", StringComparison.OrdinalIgnoreCase);
        }

        private GhnCreateOrderRequestDto BuildGhnCreateOrderRequest(Order order)
        {
            var quantity = Math.Max(1, order.OrderItems.Sum(i => i.Quantity));
            var weight = Math.Max(_ghnSettings.DefaultWeight, quantity * _ghnSettings.DefaultWeight);
            var isCod = string.Equals(order.Payment?.PaymentMethod, "COD", StringComparison.OrdinalIgnoreCase);

            return new GhnCreateOrderRequestDto
            {
                ClientOrderCode = order.OrderCode,
                ToName = order.ReceiverName,
                ToPhone = order.ReceiverPhone,
                ToAddress = order.ShippingAddress,
                ToWardCode = order.ToWardCode!,
                ToDistrictId = order.ToDistrictId!.Value,
                CodAmount = isCod ? (int)Math.Round(order.FinalAmount, 0, MidpointRounding.AwayFromZero) : 0,
                Content = $"Adidas shoes order {order.OrderCode}",
                Weight = weight,
                Length = _ghnSettings.DefaultLength,
                Width = _ghnSettings.DefaultWidth,
                Height = Math.Max(_ghnSettings.DefaultHeight, _ghnSettings.DefaultHeight * Math.Min(quantity, 4)),
                InsuranceValue = Math.Max(_ghnSettings.InsuranceValueDefault, (int)Math.Round(order.FinalAmount, 0, MidpointRounding.AwayFromZero)),
                ServiceTypeId = _ghnSettings.ServiceTypeId,
                PaymentTypeId = isCod ? _ghnSettings.PaymentTypeIdCod : _ghnSettings.PaymentTypeIdOnline,
                RequiredNote = _ghnSettings.RequiredNote,
                Items = order.OrderItems.Select(item => new GhnCreateOrderItemDto
                {
                    Name = item.ProductName,
                    Quantity = item.Quantity,
                    Price = (int)Math.Round(item.UnitPrice, 0, MidpointRounding.AwayFromZero),
                    Weight = _ghnSettings.DefaultWeight
                }).ToList()
            };
        }

        private static bool IsValidPhone(string? phone)
        {
            return !string.IsNullOrWhiteSpace(phone) &&
                   Regex.IsMatch(phone.Trim(), @"^(0|\+84)[0-9]{8,10}$");
        }

        private static string? MapOrderStatusToShipmentStatus(string? orderStatus)
        {
            return orderStatus switch
            {
                "Paid" or "Processing" => "Preparing",
                "Shipping" => "Shipped",
                "Delivered" or "Completed" => "Delivered",
                "Cancelled" => "Returned",
                _ => "Pending"
            };
        }

        private static System.Linq.Expressions.Expression<Func<Shipment, ShipmentDetailDto>> MapShipmentDetail()
        {
            return s => new ShipmentDetailDto
            {
                ShipmentId = s.ShipmentId,
                OrderId = s.OrderId,
                OrderCode = s.Order.OrderCode,
                OrderStatus = s.Order.Status,
                Carrier = s.ShippingProvider,
                TrackingNumber = s.TrackingCode,
                GhnOrderCode = s.GhnOrderCode,
                ShipmentStatus = s.Status,
                EstimatedDeliveryDate = s.ExpectedDeliveryTime,
                Note = null,
                ShippedAt = s.ShippedAt,
                DeliveredAt = s.DeliveredAt,
                ReceiverName = s.Order.ReceiverName,
                ReceiverPhone = s.Order.ReceiverPhone,
                ShippingAddress = s.Order.ShippingAddress,
                ShippingFee = s.ShippingFee,
                PaymentMethod = s.Order.Payment == null ? null : s.Order.Payment.PaymentMethod,
                PaymentStatus = s.Order.Payment == null ? null : s.Order.Payment.Status
            };
        }
    }
}
