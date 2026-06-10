namespace AdidasShoesStore.Api.DTOs.Returns;

public class ReturnRequestDto
{
    public int ReturnRequestId { get; set; }
    public int OrderId { get; set; }
    public int UserId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime? RequestedAt { get; set; }
    public string? AdminNote { get; set; }
}