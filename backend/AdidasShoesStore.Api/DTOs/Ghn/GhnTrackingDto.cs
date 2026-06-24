namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnTrackingDto
    {
        public string GhnOrderCode { get; set; } = string.Empty;

        public string? Status { get; set; }

        public string? StatusText { get; set; }

        public DateTime? LeadTime { get; set; }

        public string? RawStatus { get; set; }
    }
}
