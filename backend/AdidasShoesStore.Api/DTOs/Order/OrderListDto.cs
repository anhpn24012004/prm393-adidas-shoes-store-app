namespace AdidasShoesStore.Api.DTOs.Order
{
    public class OrderListDto
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public decimal TotalAmount { get; set; }

        public decimal ShippingFee { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal FinalAmount { get; set; }

        public string Status { get; set; } = null!;

        public string? PaymentMethod { get; set; }

        public string? PaymentStatus { get; set; }

        public string? ShipmentStatus { get; set; }

        public int? LatestRefundRequestId { get; set; }

        public string? LatestRefundRequestStatus { get; set; }

        public decimal? LatestRefundRequestAmount { get; set; }

        public string? LatestRefundRequestReason { get; set; }

        public string? GhnOrderCode { get; set; }

        public string? TrackingCode { get; set; }

        public DateTime? ExpectedDeliveryTime { get; set; }

        public DateTime? CreatedAt { get; set; }

        public bool HasReturnRequest { get; set; }

        public List<OrderItemDto> Items { get; set; } = new();
    }
}
