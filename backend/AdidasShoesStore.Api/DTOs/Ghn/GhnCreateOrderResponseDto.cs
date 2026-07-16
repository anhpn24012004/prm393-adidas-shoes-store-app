namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnCreateOrderResponseDto
    {
        public string GhnOrderCode { get; set; } = string.Empty;

        public decimal TotalFee { get; set; }

        public DateTime? ExpectedDeliveryTime { get; set; }

        public string? Status { get; set; }
    }
}
