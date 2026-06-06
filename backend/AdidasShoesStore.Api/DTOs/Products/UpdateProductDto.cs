using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Products;

public class UpdateProductDto
{
    [Required]
    public string ProductName { get; set; } = string.Empty;

    public string? Description { get; set; }

    [Range(0, double.MaxValue)]
    public decimal BasePrice { get; set; }

    [Required]
    public int CategoryId { get; set; }

    public string? Brand { get; set; } = "Adidas";
    public string? Gender { get; set; }
    public string? Material { get; set; }

    public bool IsActive { get; set; } = true;
}