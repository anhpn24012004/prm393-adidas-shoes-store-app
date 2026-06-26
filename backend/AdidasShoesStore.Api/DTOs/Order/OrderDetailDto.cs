namespace AdidasShoesStore.Api.DTOs.Order
{
    public class OrderDetailDto
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public decimal TotalAmount { get; set; }

        public decimal ShippingFee { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal FinalAmount { get; set; }

        public string Status { get; set; } = null!;

        public bool CanReview { get; set; }

        public string ShippingAddress { get; set; } = null!;

        public int? ToDistrictId { get; set; }

        public string? ToWardCode { get; set; }

        public string? ToProvinceName { get; set; }

        public string? ToDistrictName { get; set; }

        public string? ToWardName { get; set; }

        public string ReceiverName { get; set; } = null!;

        public string ReceiverPhone { get; set; } = null!;

        public string? Note { get; set; }

        public DateTime? CreatedAt { get; set; }

        public int? PaymentId { get; set; }

        public string? PaymentMethod { get; set; }

        public decimal? PaymentAmount { get; set; }

        public string? PaymentStatus { get; set; }

        public int? ShipmentId { get; set; }

        public string? ShipmentStatus { get; set; }

        public string? ShippingProvider { get; set; }

        public string? TrackingCode { get; set; }

        public string? GhnOrderCode { get; set; }

        public DateTime? ExpectedDeliveryTime { get; set; }

        public DateTime? ShippedAt { get; set; }

        public DateTime? DeliveredAt { get; set; }

        public List<OrderItemDto> Items { get; set; } = new();
    }
}
