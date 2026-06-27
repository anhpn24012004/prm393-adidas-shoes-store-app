namespace AdidasShoesStore.Api.DTOs.Returns;

public class ReturnRequestDto
{
    public int ReturnRequestId { get; set; }
    public string RequestCode { get; set; } = string.Empty;
    public int OrderId { get; set; }
    public string OrderCode { get; set; } = string.Empty;
    public int UserId { get; set; }
    public string? CustomerName { get; set; }
    public string? CustomerEmail { get; set; }
    public string? CustomerPhone { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string? CustomerNote { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime? RequestedAt { get; set; }
    public string? AdminNote { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string BankAccountNumber { get; set; } = string.Empty;
    public string BankAccountName { get; set; } = string.Empty;
    public decimal RequestedAmount { get; set; }
    public DateTime? ApprovedAt { get; set; }
    public DateTime? RejectedAt { get; set; }
    public string? ReturnCarrier { get; set; }
    public string? ReturnTrackingCode { get; set; }
    public string? ReturnShipmentNote { get; set; }
    public DateTime? ReturnShippedAt { get; set; }
    public DateTime? ReturnReceivedAt { get; set; }
    public string? InspectionNote { get; set; }
    public bool? IsRestockable { get; set; }
    public int? RestockQuantity { get; set; }
    public string? RefundTransactionNote { get; set; }
    public DateTime? RefundedAt { get; set; }
    public int? ProcessedByAdminId { get; set; }
    public string? ProcessedByAdminName { get; set; }
    public string? PaymentMethod { get; set; }
    public string? PaymentStatus { get; set; }
    public string? OrderStatus { get; set; }
    public List<ReturnItemDto> Items { get; set; } = new();
    public ShopReturnAddressDto? ShopReturnAddress { get; set; }
}

public class ReturnItemDto
{
    public int ReturnItemId { get; set; }
    public int OrderItemId { get; set; }
    public int ProductId { get; set; }
    public int ProductVariantId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal RefundAmount { get; set; }
}

public class ShopReturnAddressDto
{
    public string ShopName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public string? WardName { get; set; }
    public string? DistrictName { get; set; }
    public string? ProvinceName { get; set; }
}
