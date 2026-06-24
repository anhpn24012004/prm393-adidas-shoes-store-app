namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnCalculateFeeResponseDto
    {
        public decimal ShippingFee { get; set; }

        public decimal ServiceFee { get; set; }

        public decimal InsuranceFee { get; set; }

        public DateTime? ExpectedDeliveryTime { get; set; }
    }
}
