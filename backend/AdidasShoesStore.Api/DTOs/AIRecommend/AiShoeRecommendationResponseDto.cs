namespace AdidasShoesStore.Api.DTOs.AIRecommend;

public class AiShoeRecommendationResponseDto
{
    public string RecommendedSize { get; set; } = string.Empty;
    public string Advice { get; set; } = string.Empty;
    public List<AiRecommendedProductDto> RecommendedProducts { get; set; } = new();
}

public class AiRecommendedProductDto
{
    public int ProductId { get; set; }
    public int VariantId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public string? MainImageUrl { get; set; }
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public string Reason { get; set; } = string.Empty;
}
