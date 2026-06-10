namespace AdidasShoesStore.Api.DTOs.Returns;

public class CreateReturnRequestDto
{
    public int OrderId { get; set; }
    public int UserId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public List<CreateReturnItemDto> Items { get; set; } = new();
}

public class CreateReturnItemDto
{
    public int OrderItemId { get; set; }
    public int Quantity { get; set; }
    public string? Reason { get; set; }
}