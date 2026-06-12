namespace AdidasShoesStore.Api.DTOs.Products;

public class ProductImageDto
{
    public int ImageId { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public bool IsMain { get; set; }
}