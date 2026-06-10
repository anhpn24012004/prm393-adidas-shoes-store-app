namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class AdminShipmentListDto
    {
        public int ShipmentId { get; set; }

        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public int UserId { get; set; }

        public string CustomerName { get; set; } = null!;

        public string? ShippingProvider { get; set; }

        public string? TrackingCode { get; set; }

        public string? ShipmentStatus { get; set; }

        public string OrderStatus { get; set; } = null!;

        public DateTime? ShippedAt { get; set; }

        public DateTime? DeliveredAt { get; set; }
    }
}
