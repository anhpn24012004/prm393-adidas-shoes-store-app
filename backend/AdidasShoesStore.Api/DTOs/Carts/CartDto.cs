namespace AdidasShoesStore.Api.DTOs.Carts
{
    public class CartDto
    {
        public int CartId { get; set; }
        public int UserId { get; set; }
        public List<CartItemDto> CartItems { get; set; }
    }
}
