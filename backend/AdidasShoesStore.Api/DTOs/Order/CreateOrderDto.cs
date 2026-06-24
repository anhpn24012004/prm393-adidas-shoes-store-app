namespace AdidasShoesStore.Api.DTOs.Order
{
    public class CreateOrderDto
    {
        public int AddressId { get; set; }

        public string PaymentMethod { get; set; } = null!;

        public string? Note { get; set; }

        public int? BuyNowVariantId { get; set; }

        public int? BuyNowQuantity { get; set; }

        public int ToDistrictId { get; set; }

        public string ToWardCode { get; set; } = string.Empty;

        public string? ToProvinceName { get; set; }

        public string? ToDistrictName { get; set; }

        public string? ToWardName { get; set; }

        public decimal? ShippingFee { get; set; }
    }
}
