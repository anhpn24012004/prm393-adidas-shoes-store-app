namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class ShipmentDetailDto
    {
        public int ShipmentId { get; set; }

        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public string OrderStatus { get; set; } = null!;

        public string? Carrier { get; set; }

        public string? TrackingNumber { get; set; }

        public string? GhnOrderCode { get; set; }

        public string? ShipmentStatus { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        public string? Note { get; set; }

        public DateTime? ShippedAt { get; set; }

        public DateTime? DeliveredAt { get; set; }

        public decimal? ShippingFee { get; set; }

        public string ReceiverName { get; set; } = null!;

        public string ReceiverPhone { get; set; } = null!;

        public string ShippingAddress { get; set; } = null!;

        public string? PaymentMethod { get; set; }

        public string? PaymentStatus { get; set; }
    }
}
