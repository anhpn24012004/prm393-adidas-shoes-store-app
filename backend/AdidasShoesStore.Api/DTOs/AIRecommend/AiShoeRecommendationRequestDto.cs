namespace AdidasShoesStore.Api.DTOs.AIRecommend;

public class AiShoeRecommendationRequestDto
{
    public string Gender { get; set; } = string.Empty;
    public double FootLengthCm { get; set; }
    public string FootWidth { get; set; } = string.Empty;
    public string Purpose { get; set; } = string.Empty;
    public decimal Budget { get; set; }
    public string FavoriteColor { get; set; } = string.Empty;
}