namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class ShipmentTrackingDto
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public string OrderStatus { get; set; } = null!;

        public int ShipmentId { get; set; }

        public string? ShipmentStatus { get; set; }

        public string? Carrier { get; set; }

        public string? TrackingNumber { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        public DateTime? ShippedAt { get; set; }

        public DateTime? DeliveredAt { get; set; }

        public string ReceiverName { get; set; } = null!;

        public string ReceiverPhone { get; set; } = null!;

        public string ShippingAddress { get; set; } = null!;
    }
}
