using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Products;

public class CreateProductVariantDto
{
    [Required]
    public string Size { get; set; } = string.Empty;

    public string Color { get; set; } = string.Empty;

    public string? ImageUrl { get; set; }

    [Range(0, double.MaxValue)]
    public decimal Price { get; set; }

    [Range(0, int.MaxValue)]
    public int StockQuantity { get; set; }

    [MaxLength(100)]
    public string? Sku { get; set; }

    public bool IsActive { get; set; } = true;
}
