namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class PayPalPaymentResponseDto
    {
        public string? ApprovalUrl { get; set; }

        public string? PayPalOrderId { get; set; }

        public bool Success { get; set; }

        public string? OrderCode { get; set; }

        public string? Message { get; set; }
    }
}
