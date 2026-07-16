namespace AdidasShoesStore.Api.DTOs.Inventory;

public class StockChangedDto
{
    public int ProductId { get; set; }

    public int VariantId { get; set; }

    public int StockQuantity { get; set; }

    public int? TotalStock { get; set; }

    public bool IsInStock { get; set; }

    public DateTime UpdatedAt { get; set; }

    public string? Reason { get; set; }
}
