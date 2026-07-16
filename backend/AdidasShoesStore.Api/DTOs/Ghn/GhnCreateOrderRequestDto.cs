namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnCreateOrderRequestDto
    {
        public string ClientOrderCode { get; set; } = string.Empty;

        public string ToName { get; set; } = string.Empty;

        public string ToPhone { get; set; } = string.Empty;

        public string ToAddress { get; set; } = string.Empty;

        public string ToWardCode { get; set; } = string.Empty;

        public int ToDistrictId { get; set; }

        public int CodAmount { get; set; }

        public string Content { get; set; } = string.Empty;

        public int Weight { get; set; }

        public int Length { get; set; }

        public int Width { get; set; }

        public int Height { get; set; }

        public int InsuranceValue { get; set; }

        public int ServiceTypeId { get; set; }

        public int PaymentTypeId { get; set; }

        public string RequiredNote { get; set; } = string.Empty;

        public List<GhnCreateOrderItemDto> Items { get; set; } = new();
    }

    public class GhnCreateOrderItemDto
    {
        public string Name { get; set; } = string.Empty;

        public int Quantity { get; set; }

        public int Price { get; set; }

        public int Weight { get; set; }
    }
}
