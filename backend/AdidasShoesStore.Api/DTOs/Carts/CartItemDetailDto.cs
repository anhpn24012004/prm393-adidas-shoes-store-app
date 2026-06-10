namespace AdidasShoesStore.Api.DTOs.Carts;

public class CartItemDetailDto
{
    public int CartItemId { get; set; }
    public int VariantId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string? ImageUrl { get; set; }
    public int Quantity { get; set; }
}
