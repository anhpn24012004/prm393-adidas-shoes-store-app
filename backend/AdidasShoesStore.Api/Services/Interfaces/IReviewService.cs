using AdidasShoesStore.Api.DTOs.Reviews;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IReviewService
{
    Task<List<ReviewDto>> GetReviewsByProductIdAsync(int productId);
    Task<ReviewDto?> GetUserReviewAsync(int userId, int productId);
    Task<ReviewDto?> CreateReviewAsync(CreateReviewDto dto);
    Task<ReviewDto?> UpdateReviewAsync(int reviewId, UpdateReviewDto dto);
}
