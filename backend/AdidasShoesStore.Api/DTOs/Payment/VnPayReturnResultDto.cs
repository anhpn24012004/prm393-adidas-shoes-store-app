namespace AdidasShoesStore.Api.DTOs.Payment
{
    public class VnPayReturnResultDto
    {
        public bool Success { get; set; }

        public int? OrderId { get; set; }

        public string? OrderCode { get; set; }

        public string Message { get; set; } = null!;
    }
}
