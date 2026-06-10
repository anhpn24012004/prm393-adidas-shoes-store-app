using AdidasShoesStore.Api.DTOs.AIRecommend;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AiAssistantController : ControllerBase
{
    private readonly IAiAssistantService _aiAssistantService;

    public AiAssistantController(IAiAssistantService aiAssistantService)
    {
        _aiAssistantService = aiAssistantService;
    }

    [HttpPost("shoe-recommendation")]
    public async Task<IActionResult> RecommendShoes(
        [FromBody] AiShoeRecommendationRequestDto request)
    {
        if (request.FootLengthCm <= 0)
        {
            return BadRequest("Foot length must be greater than 0.");
        }

        if (request.Budget <= 0)
        {
            return BadRequest("Budget must be greater than 0.");
        }

        var result = await _aiAssistantService.RecommendShoesAsync(request);

        return Ok(result);
    }
}