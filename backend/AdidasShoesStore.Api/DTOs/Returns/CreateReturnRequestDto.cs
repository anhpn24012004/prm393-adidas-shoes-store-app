namespace AdidasShoesStore.Api.DTOs.Returns;

public class CreateReturnRequestDto
{
    public int OrderId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string? CustomerNote { get; set; }
    public string BankName { get; set; } = string.Empty;
    public string BankAccountNumber { get; set; } = string.Empty;
    public string BankAccountName { get; set; } = string.Empty;
    public List<CreateReturnItemDto> Items { get; set; } = new();
}

public class CreateReturnItemDto
{
    public int OrderItemId { get; set; }
    public int Quantity { get; set; }
    public string? Reason { get; set; }
}

public class ReviewReturnRequestDto
{
    public string? AdminNote { get; set; }
}

public class ReturnShippingInfoDto
{
    public string ReturnCarrier { get; set; } = string.Empty;
    public string ReturnTrackingCode { get; set; } = string.Empty;
    public string? ReturnShipmentNote { get; set; }
}

public class InspectReturnRequestDto
{
    public string? InspectionNote { get; set; }
    public bool IsRestockable { get; set; }
    public int RestockQuantity { get; set; }
}

public class MarkRefundedReturnRequestDto
{
    public string? RefundTransactionNote { get; set; }
    public string? AdminNote { get; set; }
}
