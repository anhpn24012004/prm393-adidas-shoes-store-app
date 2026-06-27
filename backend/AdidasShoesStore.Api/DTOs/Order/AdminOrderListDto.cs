namespace AdidasShoesStore.Api.DTOs.Order
{
    public class AdminOrderListDto
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public string CustomerName { get; set; } = null!;

        public string CustomerEmail { get; set; } = null!;

        public string ReceiverName { get; set; } = null!;

        public string ReceiverPhone { get; set; } = null!;

        public decimal FinalAmount { get; set; }

        public string Status { get; set; } = null!;

        public string? PaymentMethod { get; set; }

        public string? PaymentStatus { get; set; }

        public int? LatestRefundRequestId { get; set; }

        public string? LatestRefundRequestStatus { get; set; }

        public decimal? LatestRefundRequestAmount { get; set; }

        public string? LatestRefundRequestReason { get; set; }

        public DateTime? CreatedAt { get; set; }
    }
}
