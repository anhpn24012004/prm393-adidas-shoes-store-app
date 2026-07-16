namespace AdidasShoesStore.Api.DTOs.Payment;

public class SePayPaymentResponseDto
{
    public int OrderId { get; set; }

    public decimal Amount { get; set; }

    public string BankCode { get; set; } = string.Empty;

    public string BankAccountNumber { get; set; } = string.Empty;

    public string AccountName { get; set; } = string.Empty;

    public string TransferContent { get; set; } = string.Empty;

    public string QrCodeUrl { get; set; } = string.Empty;

    public string PaymentStatus { get; set; } = string.Empty;

    public DateTime? ExpiresAt { get; set; }
}
