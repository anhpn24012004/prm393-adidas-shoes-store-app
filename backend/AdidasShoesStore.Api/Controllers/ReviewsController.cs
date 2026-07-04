using AdidasShoesStore.Api.DTOs.Reviews;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ReviewsController : ControllerBase
{
    private readonly IReviewService _reviewService;

    public ReviewsController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpGet("product/{productId}")]
    public async Task<IActionResult> GetReviewsByProduct(int productId)
    {
        var reviews = await _reviewService.GetReviewsByProductIdAsync(productId);
        return Ok(reviews);
    }

    [Authorize]
    [HttpGet("my/product/{productId}")]
    public async Task<IActionResult> GetMyReview(int productId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var review = await _reviewService.GetUserReviewAsync(userId, productId);

        if (review == null)
        {
            return NotFound(new { message = "Review not found" });
        }

        return Ok(review);
    }

    [Authorize]
    [Obsolete("Use GET /api/reviews/my/product/{productId}.")]
    [HttpGet("user/{userId}/product/{productId}")]
    public async Task<IActionResult> GetUserReview(int userId, int productId)
    {
        if (!TryGetUserId(out var tokenUserId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        if (tokenUserId != userId && !User.IsInRole("Admin"))
        {
            return Forbid();
        }

        var review = await _reviewService.GetUserReviewAsync(userId, productId);

        if (review == null)
        {
            return NotFound(new { message = "Review not found" });
        }

        return Ok(review);
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> CreateReview([FromBody] CreateReviewDto dto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var result = await _reviewService.CreateReviewAsync(userId, dto);

        if (result == null)
        {
            return BadRequest("Chỉ có thể đánh giá sản phẩm sau khi đơn hàng đã hoàn thành, chưa trả/hoàn hàng và chưa từng đánh giá sản phẩm này.");
        }

        return Ok(result);
    }

    [Authorize]
    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateReview(int id, [FromBody] UpdateReviewDto dto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var result = await _reviewService.UpdateReviewAsync(userId, id, dto, User.IsInRole("Admin"));

        if (result == null)
        {
            return BadRequest("Chỉ được sửa đánh giá 1 lần. Sau khi sửa, bạn không thể đánh giá lại sản phẩm này.");
        }

        return Ok(result);
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(value, out userId);
    }
}
