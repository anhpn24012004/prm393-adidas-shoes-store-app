namespace AdidasShoesStore.Api.DTOs.Wishlists;

public class AddToWishlistDto
{
    public int UserId { get; set; }
    public int ProductId { get; set; }
    public int? VariantId { get; set; }
}
