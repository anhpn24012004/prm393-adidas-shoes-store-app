namespace AdidasShoesStore.Api.DTOs.RefundRequests;

public class CreateRefundRequestDto
{
    public int OrderId { get; set; }

    public string Reason { get; set; } = string.Empty;

    public decimal RequestedAmount { get; set; }

    public string BankName { get; set; } = string.Empty;

    public string BankAccountNumber { get; set; } = string.Empty;

    public string BankAccountName { get; set; } = string.Empty;

    public string? CustomerNote { get; set; }

    public string? ProofImageUrl { get; set; }
}
