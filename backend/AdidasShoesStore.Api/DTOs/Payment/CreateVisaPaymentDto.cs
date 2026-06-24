namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class CreateVisaPaymentDto
    {
        public int OrderId { get; set; }

        public string CardNumber { get; set; } = null!;

        public string CardHolderName { get; set; } = null!;

        public string ExpiryMonth { get; set; } = null!;

        public string ExpiryYear { get; set; } = null!;

        public string Cvv { get; set; } = null!;

        public decimal? Amount { get; set; }
    }
}
