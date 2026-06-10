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

    [HttpPost]
    public async Task<IActionResult> CreateReview([FromBody] CreateReviewDto dto)
    {
        var result = await _reviewService.CreateReviewAsync(dto);

        if (result == null)
        {
            return BadRequest("Invalid review data.");
        }

        return Ok(result);
    }
}