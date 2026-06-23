namespace AdidasShoesStore.Api.DTOs.Products;

using System.Text.Json.Serialization;

public class ProductDetailDto
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal BasePrice { get; set; }
    public int CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public string? Brand { get; set; }
    public string? Gender { get; set; }
    public string? Material { get; set; }
    public double AverageRating { get; set; }
    public int ReviewCount { get; set; }
    public bool IsActive { get; set; }
    public List<ProductClassificationGroupDto> ClassificationGroups { get; set; } = new();
    [JsonIgnore]
    public string? ClassificationGroupsJson { get; set; }

    public List<ProductImageDto> Images { get; set; } = new();
    public List<ProductVariantDto> Variants { get; set; } = new();
}
