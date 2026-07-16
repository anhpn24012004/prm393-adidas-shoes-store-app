using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.Returns;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/return-requests")]
[Route("api/returnrequests")]
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

    [HttpGet("my")]
    public async Task<IActionResult> GetMy()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.GetByUserIdAsync(userId);
        return Ok(result);
    }

    [HttpGet("my/{id:int}")]
    public async Task<IActionResult> GetMyById(int id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.GetByUserIdAsync(userId, id);
        return result == null ? NotFound(new { message = "Return request not found" }) : Ok(result);
    }

    [Obsolete("Use /api/return-requests/my instead.")]
    [HttpGet("user/{userId:int}")]
    public async Task<IActionResult> GetByUserId(int userId)
    {
        if (!TryGetUserId(out var tokenUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        if (tokenUserId != userId && !User.IsInRole("Admin"))
        {
            return Forbid();
        }

        var result = await _returnRequestService.GetByUserIdAsync(userId);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateReturnRequestDto dto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.CreateAsync(userId, dto);

        if (result == null)
        {
            return BadRequest(new
            {
                message = "Invalid return request. Order must be delivered/completed, payment must be success, and selected quantities must be available."
            });
        }

        return Ok(result);
    }

    [HttpPut("{id:int}/shipping-info")]
    public async Task<IActionResult> UpdateShippingInfo(int id, [FromBody] ReturnShippingInfoDto dto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.UpdateShippingInfoAsync(userId, id, dto);
        return result == null
            ? BadRequest(new { message = "Cannot update return shipping info." })
            : Ok(result);
    }

    [HttpPost("evidence")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(5_242_880)]
    public async Task<IActionResult> UploadEvidence(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { message = "File is required." });
        }

        if (file.Length > 5 * 1024 * 1024)
        {
            return BadRequest(new { message = "Evidence image must be 5MB or smaller." });
        }

        var allowedExtensions = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg", ".jpeg", ".png", ".webp"
        };

        var extension = Path.GetExtension(file.FileName);
        if (!allowedExtensions.Contains(extension))
        {
            return BadRequest(new { message = "Only .jpg, .jpeg, .png and .webp evidence images are allowed." });
        }

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

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}/approve")]
    [HttpPost("{id:int}/approve")]
    public async Task<IActionResult> Approve(int id, [FromBody] ReviewReturnRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.ApproveAsync(id, adminUserId, dto);
        return result == null ? BadRequest(new { message = "Cannot approve this return request." }) : Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPut("{id:int}/reject")]
    [HttpPost("{id:int}/reject")]
    public async Task<IActionResult> Reject(int id, [FromBody] ReviewReturnRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.RejectAsync(id, adminUserId, dto);
        return result == null ? BadRequest(new { message = "Cannot reject this return request. Admin note is required." }) : Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("{id:int}/mark-received")]
    public async Task<IActionResult> MarkReceived(int id, [FromBody] ReviewReturnRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.MarkReceivedAsync(id, adminUserId, dto);
        return result == null ? BadRequest(new { message = "Cannot mark this return as received." }) : Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("{id:int}/inspect")]
    public async Task<IActionResult> Inspect(int id, [FromBody] InspectReturnRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.InspectAsync(id, adminUserId, dto);
        return result == null ? BadRequest(new { message = "Cannot inspect this return request." }) : Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("{id:int}/mark-refunded")]
    public async Task<IActionResult> MarkRefunded(int id, [FromBody] MarkRefundedReturnRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _returnRequestService.MarkRefundedAsync(id, adminUserId, dto);
        return result == null ? BadRequest(new { message = "Cannot mark this return as refunded." }) : Ok(result);
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId);
    }
}
