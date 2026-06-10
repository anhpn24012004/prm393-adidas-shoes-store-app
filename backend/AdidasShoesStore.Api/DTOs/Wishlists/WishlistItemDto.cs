namespace AdidasShoesStore.Api.DTOs.Wishlists;

public class WishlistItemDto
{
    public int WishlistId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal BasePrice { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime? CreatedAt { get; set; }
}
