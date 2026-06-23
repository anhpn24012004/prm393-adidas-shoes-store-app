namespace AdidasShoesStore.Api.DTOs.Products;

using System.Text.Json.Serialization;

public class ProductVariantDto
{
    public int VariantId { get; set; }
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string? ImageUrl { get; set; }
    public List<string> OptionValues { get; set; } = new();
    [JsonIgnore]
    public string? OptionValuesJson { get; set; }
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string? Sku { get; set; }
    public bool IsActive { get; set; }
}
