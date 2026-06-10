namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class UpdateTrackingInfoDto
    {
        public string? Carrier { get; set; }

        public string? TrackingNumber { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        public string? Note { get; set; }
    }
}
