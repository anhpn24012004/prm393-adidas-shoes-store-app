namespace AdidasShoesStore.Api.DTOs.Products;

public class ProductVariantDto
{
    public int VariantId { get; set; }
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string? Sku { get; set; }
    public bool IsActive { get; set; }
}