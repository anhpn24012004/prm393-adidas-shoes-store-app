namespace AdidasShoesStore.Api.DTOs.RefundRequests;

public class RefundRequestDto
{
    public int RefundRequestId { get; set; }

    public int OrderId { get; set; }

    public int UserId { get; set; }

    public string RequestCode { get; set; } = string.Empty;

    public string Reason { get; set; } = string.Empty;

    public decimal RequestedAmount { get; set; }

    public string BankName { get; set; } = string.Empty;

    public string BankAccountNumber { get; set; } = string.Empty;

    public string BankAccountName { get; set; } = string.Empty;

    public string? CustomerNote { get; set; }

    public string Status { get; set; } = string.Empty;

    public DateTime? CreatedAt { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public DateTime? RejectedAt { get; set; }

    public DateTime? RefundedAt { get; set; }

    public string? AdminNote { get; set; }

    public string? ProofImageUrl { get; set; }

    public string? RefundTransactionNote { get; set; }
}
