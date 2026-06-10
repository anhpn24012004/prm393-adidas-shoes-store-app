namespace AdidasShoesStore.Api.DTOs.Shipments
{
    public class CreateShipmentDto
    {
        public int OrderId { get; set; }

        public string? Carrier { get; set; }

        public string? TrackingNumber { get; set; }

        public DateTime? EstimatedDeliveryDate { get; set; }

        public string? Note { get; set; }
    }
}
