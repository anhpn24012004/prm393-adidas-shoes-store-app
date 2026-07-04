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
        if (request.FootLengthCm < 20 || request.FootLengthCm > 32)
        {
            return BadRequest(new
            {
                message = "Chiều dài bàn chân phải nằm trong khoảng 20-32 cm."
            });
        }

        if (request.Budget < 0)
        {
            return BadRequest(new
            {
                message = "Ngân sách phải là số dương."
            });
        }

        var result = await _aiAssistantService.RecommendShoesAsync(request);

        return Ok(result);
    }

    [HttpGet("health")]
    public IActionResult GeminiHealth()
    {
        return Ok(_aiAssistantService.GetGeminiHealth());
    }

    [HttpGet("test-gemini")]
    public IActionResult TestGemini()
    {
        return Ok(_aiAssistantService.GetGeminiHealth());
    }
}
