using AdidasShoesStore.Api.DTOs.Reviews;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

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

    [HttpGet("user/{userId}/product/{productId}")]
    public async Task<IActionResult> GetUserReview(int userId, int productId)
    {
        var review = await _reviewService.GetUserReviewAsync(userId, productId);

        if (review == null)
        {
            return NotFound(new { message = "Review not found" });
        }

        return Ok(review);
    }

    [HttpPost]
    public async Task<IActionResult> CreateReview([FromBody] CreateReviewDto dto)
    {
        var result = await _reviewService.CreateReviewAsync(dto);

        if (result == null)
        {
            return BadRequest("Chỉ có thể đánh giá sản phẩm sau khi đơn hàng đã hoàn thành, chưa trả/hoàn hàng và chưa từng đánh giá sản phẩm này.");
        }

        return Ok(result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateReview(int id, [FromBody] UpdateReviewDto dto)
    {
        var result = await _reviewService.UpdateReviewAsync(id, dto);

        if (result == null)
        {
            return BadRequest("Chỉ được sửa đánh giá 1 lần. Sau khi sửa, bạn không thể đánh giá lại sản phẩm này.");
        }

        return Ok(result);
    }
}
