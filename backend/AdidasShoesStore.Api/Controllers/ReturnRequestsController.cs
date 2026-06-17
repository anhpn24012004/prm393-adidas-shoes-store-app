using AdidasShoesStore.Api.DTOs.Returns;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ReturnRequestsController : ControllerBase
{
    private readonly IReturnRequestService _returnRequestService;
    private readonly IWebHostEnvironment _environment;

    public ReturnRequestsController(
        IReturnRequestService returnRequestService,
        IWebHostEnvironment environment)
    {
        _returnRequestService = returnRequestService;
        _environment = environment;
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _returnRequestService.GetAllAsync();
        return Ok(result);
    }

    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetByUserId(int userId)
    {
        var result = await _returnRequestService.GetByUserIdAsync(userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateReturnRequestDto dto)
    {
        var result = await _returnRequestService.CreateAsync(dto);

        if (result == null)
            return BadRequest("Invalid return request. Order must be delivered/completed and items must belong to the order.");

        return Ok(result);
    }

    [HttpPost("evidence")]
    [RequestSizeLimit(50_000_000)]
    public async Task<IActionResult> UploadEvidence([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "File is required." });

        var allowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp", ".gif", ".mp4", ".mov", ".webm"
        };

        var extension = Path.GetExtension(file.FileName);

        if (!allowedExtensions.Contains(extension))
            return BadRequest(new { message = "Unsupported evidence file type." });

        var webRoot = _environment.WebRootPath ??
            Path.Combine(_environment.ContentRootPath, "wwwroot");
        var uploadsRoot = Path.Combine(webRoot, "uploads", "returns");

        Directory.CreateDirectory(uploadsRoot);

        var fileName = $"{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
        var filePath = Path.Combine(uploadsRoot, fileName);

        await using (var stream = System.IO.File.Create(filePath))
        {
            await file.CopyToAsync(stream);
        }

        return Ok(new { url = $"/uploads/returns/{fileName}" });
    }

    [HttpPut("{id}/approve")]
    public async Task<IActionResult> Approve(int id, [FromBody] string? adminNote)
    {
        var success = await _returnRequestService.ApproveAsync(id, adminNote);

        if (!success)
            return BadRequest("Cannot approve this return request.");

        return Ok("Return request approved.");
    }

    [HttpPut("{id}/reject")]
    public async Task<IActionResult> Reject(int id, [FromBody] string? adminNote)
    {
        var success = await _returnRequestService.RejectAsync(id, adminNote);

        if (!success)
            return BadRequest("Cannot reject this return request.");

        return Ok("Return request rejected.");
    }
}
