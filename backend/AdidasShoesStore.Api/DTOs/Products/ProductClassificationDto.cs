using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Products;

public class ProductClassificationGroupDto
{
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public List<ProductClassificationOptionDto> Options { get; set; } = new();
}

public class ProductClassificationOptionDto
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? ImageUrl { get; set; }
    public int SortOrder { get; set; }
}

public class SyncProductClassificationsDto
{
    [MinLength(1)]
    [MaxLength(2)]
    public List<ProductClassificationGroupDto> ClassificationGroups { get; set; } = new();
    public List<SyncProductVariantDto> Variants { get; set; } = new();
}

public class SyncProductVariantDto
{
    public int? VariantId { get; set; }
    public List<string> OptionValues { get; set; } = new();
    [Range(0, double.MaxValue)]
    public decimal Price { get; set; }
    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }
    public string? Sku { get; set; }
    public bool IsActive { get; set; } = true;
    public string? ImageUrl { get; set; }
}
