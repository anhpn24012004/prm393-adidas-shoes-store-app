namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class CreatePayPalPaymentDto
    {
        public int OrderId { get; set; }

        public string? ReturnUrl { get; set; }

        public string? CancelUrl { get; set; }
    }
}
