using AdidasShoesStore.Api.DTOs.AIRecommend;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IAiAssistantService
{
    Task<AiShoeRecommendationResponseDto> RecommendShoesAsync(
        AiShoeRecommendationRequestDto request);
}