namespace AdidasShoesStore.Api.DTOs.Order
{
    public class OrderItemDto
    {
        public int OrderItemId { get; set; }

        public int VariantId { get; set; }

        public int ProductId { get; set; }

        public string ProductName { get; set; } = null!;

        public string? ImageUrl { get; set; }

        public string Size { get; set; } = null!;

        public string Color { get; set; } = null!;

        public int Quantity { get; set; }

        public decimal UnitPrice { get; set; }

        public decimal Subtotal { get; set; }
    }
}
