namespace AdidasShoesStore.Api.DTOs.AIRecommend;

public class AiShoeRecommendationResponseDto
{
    public bool Success { get; set; } = true;
    public bool IsAiGenerated { get; set; }
    public bool ColorFallback { get; set; }
    public bool BudgetFallback { get; set; }
    public int RecommendedSize { get; set; }
    public string SizeAdvice { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;
    public string? FitWarning { get; set; }
    public List<string> Warnings { get; set; } = new();
    public List<string> BuyingTips { get; set; } = new();
    public List<AiRecommendedProductDto> Recommendations { get; set; } = new();
}

public class AiRecommendedProductDto
{
    public int ProductId { get; set; }
    public int VariantId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public string? MainImageUrl { get; set; }
    public string? ImageUrl { get; set; }
    public string Size { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public int StockQuantity { get; set; }
    public int MatchScore { get; set; }
    public string Reason { get; set; } = string.Empty;
    public List<string> ReasonTags { get; set; } = new();
}

public class AiGeneratedAdviceDto
{
    public string Summary { get; set; } = string.Empty;
    public string SizeAdvice { get; set; } = string.Empty;
    public string? FitWarning { get; set; }
    public List<string> BuyingTips { get; set; } = new();
}
