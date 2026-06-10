namespace AdidasShoesStore.Api.DTOs.Order
{
    public class CreateOrderDto
    {
        public int AddressId { get; set; }

        public string PaymentMethod { get; set; } = null!;

        public string? Note { get; set; }
    }
}