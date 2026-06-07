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
                CreatedAt = r.CreatedAt
            })
            .ToListAsync();
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
            CreatedAt = review.CreatedAt
        };
    }
}