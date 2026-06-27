namespace AdidasShoesStore.Api.DTOs.RefundRequests;

public class AdminRefundRequestDetailDto : RefundRequestDto
{
    public string OrderCode { get; set; } = string.Empty;

    public string CustomerName { get; set; } = string.Empty;

    public string CustomerEmail { get; set; } = string.Empty;

    public string? CustomerPhone { get; set; }

    public string PaymentMethod { get; set; } = string.Empty;

    public string PaymentStatus { get; set; } = string.Empty;

    public string OrderStatus { get; set; } = string.Empty;

    public decimal FinalAmount { get; set; }

    public int? ShipmentId { get; set; }

    public string? ShipmentStatus { get; set; }

    public string? TrackingCode { get; set; }

    public string? GhnOrderCode { get; set; }

    public DateTime? PaidAt { get; set; }

    public int? ProcessedByAdminId { get; set; }

    public string? ProcessedByAdminName { get; set; }

    public string? ProcessedByAdminEmail { get; set; }
}
