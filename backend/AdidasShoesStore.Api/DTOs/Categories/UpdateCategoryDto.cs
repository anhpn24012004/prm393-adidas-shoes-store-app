using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Categories;

public class UpdateCategoryDto
{
    [Required]
    [MaxLength(100)]
    public string CategoryName { get; set; } = string.Empty;

    [MaxLength(255)]
    public string? Description { get; set; }
}