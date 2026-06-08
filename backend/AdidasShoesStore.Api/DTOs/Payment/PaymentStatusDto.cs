namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class PaymentStatusDto
    {
        public int OrderId { get; set; }

        public string OrderCode { get; set; } = null!;

        public string OrderStatus { get; set; } = null!;

        public string PaymentMethod { get; set; } = null!;

        public string PaymentStatus { get; set; } = null!;

        public decimal Amount { get; set; }

        public string? TransactionCode { get; set; }

        public DateTime? PaidAt { get; set; }
    }
}
