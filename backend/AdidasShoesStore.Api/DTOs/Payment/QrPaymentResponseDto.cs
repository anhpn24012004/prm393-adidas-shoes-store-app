namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class QrPaymentResponseDto
    {
        public string QrImageUrl { get; set; } = null!;

        public string BankBin { get; set; } = null!;

        public string AccountNo { get; set; } = null!;

        public string AccountName { get; set; } = null!;

        public string TransferContent { get; set; } = null!;

        public decimal Amount { get; set; }
    }
}
