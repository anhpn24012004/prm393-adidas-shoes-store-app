namespace AdidasShoesStore.Api.DTOs.Refunds;

public class RefundDto
{
    public int RefundId { get; set; }
    public int ReturnRequestId { get; set; }
    public int OrderId { get; set; }
    public decimal Amount { get; set; }
    public string Status { get; set; } = string.Empty;
    public string? PaymentMethod { get; set; }
    public string? TransactionCode { get; set; }
    public DateTime? RefundedAt { get; set; }
}