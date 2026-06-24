namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnCalculateFeeRequestDto
    {
        public int ToDistrictId { get; set; }

        public string ToWardCode { get; set; } = string.Empty;

        public int? ServiceTypeId { get; set; }

        public int? InsuranceValue { get; set; }

        public List<GhnFeeItemDto> Items { get; set; } = new();
    }

    public class GhnFeeItemDto
    {
        public int Quantity { get; set; }

        public int? Weight { get; set; }

        public int? Length { get; set; }

        public int? Width { get; set; }

        public int? Height { get; set; }
    }
}
