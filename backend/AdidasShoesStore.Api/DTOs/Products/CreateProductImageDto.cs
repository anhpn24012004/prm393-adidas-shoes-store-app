using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Products;

public class CreateProductImageDto
{
    [Required]
    public string ImageUrl { get; set; } = string.Empty;

    public bool IsMain { get; set; } = false;
}