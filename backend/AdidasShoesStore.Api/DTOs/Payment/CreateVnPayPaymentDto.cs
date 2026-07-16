namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class CreateVnPayPaymentDto
    {
        public int OrderId { get; set; }

        public string? ReturnUrl { get; set; }
    }
}
