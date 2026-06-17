using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Reviews;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class ReviewService : IReviewService
{
    private readonly AdidasShoesStoreContext _context;

    public ReviewService(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    public async Task<List<ReviewDto>> GetReviewsByProductIdAsync(int productId)
    {
        return await _context.Reviews
            .Where(r => r.ProductId == productId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new ReviewDto
            {
                ReviewId = r.ReviewId,
                UserId = r.UserId,
                ProductId = r.ProductId,
                Rating = r.Rating,
                Comment = r.Comment,
                CreatedAt = r.CreatedAt,
                EditCount = r.EditCount,
                CanEdit = r.EditCount == 0
            })
            .ToListAsync();
    }

    public async Task<ReviewDto?> GetUserReviewAsync(int userId, int productId)
    {
        var review = await _context.Reviews
            .AsNoTracking()
            .FirstOrDefaultAsync(r =>
                r.UserId == userId &&
                r.ProductId == productId);

        return review == null ? null : ToDto(review);
    }

    public async Task<ReviewDto?> CreateReviewAsync(CreateReviewDto dto)
    {
        if (dto.Rating < 1 || dto.Rating > 5)
        {
            return null;
        }

        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == dto.ProductId);

        if (!productExists)
        {
            return null;
        }

        var userExists = await _context.Users
            .AnyAsync(u => u.UserId == dto.UserId);

        if (!userExists)
        {
            return null;
        }

        var hasPurchased = await CanReviewProductAsync(dto.UserId, dto.ProductId);

        if (!hasPurchased)
        {
            return null;
        }

        var alreadyReviewed = await _context.Reviews
            .AnyAsync(r =>
                r.UserId == dto.UserId &&
                r.ProductId == dto.ProductId
            );

        if (alreadyReviewed)
        {
            return null;
        }

        var review = new Review
        {
            UserId = dto.UserId,
            ProductId = dto.ProductId,
            Rating = dto.Rating,
            Comment = dto.Comment,
            CreatedAt = DateTime.Now
        };

        _context.Reviews.Add(review);
        await _context.SaveChangesAsync();

        return new ReviewDto
        {
            ReviewId = review.ReviewId,
            UserId = review.UserId,
            ProductId = review.ProductId,
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt,
            EditCount = review.EditCount,
            CanEdit = review.EditCount == 0
        };
    }

    public async Task<ReviewDto?> UpdateReviewAsync(int reviewId, UpdateReviewDto dto)
    {
        if (dto.Rating < 1 || dto.Rating > 5)
        {
            return null;
        }

        var review = await _context.Reviews
            .FirstOrDefaultAsync(r =>
                r.ReviewId == reviewId &&
                r.UserId == dto.UserId);

        if (review == null || review.EditCount >= 1)
        {
            return null;
        }

        var canStillReview = await CanReviewProductAsync(
            dto.UserId,
            review.ProductId);

        if (!canStillReview)
        {
            return null;
        }

        review.Rating = dto.Rating;
        review.Comment = dto.Comment;
        review.EditCount += 1;

        await _context.SaveChangesAsync();

        return ToDto(review);
    }

    private static ReviewDto ToDto(Review review)
    {
        return new ReviewDto
        {
            ReviewId = review.ReviewId,
            UserId = review.UserId,
            ProductId = review.ProductId,
            Rating = review.Rating,
            Comment = review.Comment,
            CreatedAt = review.CreatedAt,
            EditCount = review.EditCount,
            CanEdit = review.EditCount == 0
        };
    }

    private async Task<bool> CanReviewProductAsync(int userId, int productId)
    {
        return await _context.Orders
            .AnyAsync(o =>
                o.UserId == userId &&
                o.Status == "Completed" &&
                !o.ReturnRequests.Any() &&
                o.OrderItems.Any(oi =>
                    oi.Variant.ProductId == productId
                )
            );
    }
}
