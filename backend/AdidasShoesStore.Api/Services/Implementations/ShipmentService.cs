using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Shipments;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class ShipmentService : IShipmentService
    {
        private static readonly Dictionary<string, string[]> AllowedTransitions = new(StringComparer.Ordinal)
        {
            ["Pending"] = new[] { "Preparing" },
            ["Preparing"] = new[] { "Shipped" },
            ["Shipped"] = new[] { "InTransit" },
            ["InTransit"] = new[] { "OutForDelivery" },
            ["OutForDelivery"] = new[] { "Delivered", "Failed" },
            ["Failed"] = new[] { "OutForDelivery", "Returned" }
        };

        private readonly AdidasShoesStoreContext _context;

        public ShipmentService(AdidasShoesStoreContext context)
        {
            _context = context;
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
            return await _context.Shipments
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
                    EstimatedDeliveryDate = null,
                    ShippedAt = s.ShippedAt,
                    DeliveredAt = s.DeliveredAt,
                    ReceiverName = s.Order.ReceiverName,
                    ReceiverPhone = s.Order.ReceiverPhone,
                    ShippingAddress = s.Order.ShippingAddress
                })
                .FirstOrDefaultAsync();
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
                    ShipmentStatus = s.Status,
                    EstimatedDeliveryDate = null,
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

            if (order.Status != "Processing" && order.Status != "Paid")
            {
                return ShipmentServiceResult<AdminShipmentDetailDto>.Fail(
                    "Shipment can only be created for orders with status Processing or Paid"
                );
            }

            var shipment = new Shipment
            {
                OrderId = order.OrderId,
                ShippingProvider = dto.Carrier,
                TrackingCode = dto.TrackingNumber,
                Status = "Shipped",
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

            if (newStatus == "Delivered")
            {
                shipment.DeliveredAt = DateTime.Now;
                shipment.Order.Status = "Delivered";

                if (shipment.Order.Payment != null &&
                    string.Equals(shipment.Order.Payment.PaymentMethod, "COD", StringComparison.OrdinalIgnoreCase))
                {
                    shipment.Order.Payment.Status = "Success";
                    shipment.Order.Payment.PaidAt = DateTime.Now;
                    shipment.Order.Payment.TransactionCode = $"COD-{shipment.Order.OrderCode}";
                }
            }
            else if (newStatus == "Returned")
            {
                shipment.Order.Status = "Cancelled";
            }

            await _context.SaveChangesAsync();

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
                ShipmentStatus = s.Status,
                EstimatedDeliveryDate = null,
                Note = null,
                ShippedAt = s.ShippedAt,
                DeliveredAt = s.DeliveredAt,
                ReceiverName = s.Order.ReceiverName,
                ReceiverPhone = s.Order.ReceiverPhone,
                ShippingAddress = s.Order.ShippingAddress,
                PaymentMethod = s.Order.Payment == null ? null : s.Order.Payment.PaymentMethod,
                PaymentStatus = s.Order.Payment == null ? null : s.Order.Payment.Status
            };
        }
    }
}
