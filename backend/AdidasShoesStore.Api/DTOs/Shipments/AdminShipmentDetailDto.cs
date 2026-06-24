namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class AdminShipmentDetailDto
    {
        public int ShipmentId { get; set; }

        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public string OrderStatus { get; set; } = null!;

        public DateTime? OrderCreatedAt { get; set; }

        public int UserId { get; set; }

        public string CustomerName { get; set; } = null!;

        public string CustomerEmail { get; set; } = null!;

        public string? CustomerPhone { get; set; }

        public string ReceiverName { get; set; } = null!;

        public string ReceiverPhone { get; set; } = null!;

        public string ShippingAddress { get; set; } = null!;

        public string? Carrier { get; set; }

        public string? TrackingNumber { get; set; }

        public string? GhnOrderCode { get; set; }

        public string? ShipmentStatus { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        public string? Note { get; set; }

        public DateTime? ShippedAt { get; set; }

        public DateTime? DeliveredAt { get; set; }

        public string? PaymentMethod { get; set; }

        public string? PaymentStatus { get; set; }

        public string? TransactionCode { get; set; }

        public DateTime? PaidAt { get; set; }

        public decimal TotalAmount { get; set; }

        public decimal ShippingFee { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal FinalAmount { get; set; }

        public List<AdminShipmentOrderItemDto> OrderItems { get; set; } = new();
    }
}
