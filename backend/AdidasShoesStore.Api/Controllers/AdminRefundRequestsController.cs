using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.RefundRequests;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Authorize(Roles = "Admin")]
[ApiController]
[Route("api/admin/refund-requests")]
public class AdminRefundRequestsController : ControllerBase
{
    private readonly IRefundRequestService _refundRequestService;

    public AdminRefundRequestsController(IRefundRequestService refundRequestService)
    {
        _refundRequestService = refundRequestService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _refundRequestService.GetAdminListAsync();
        return Ok(result);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _refundRequestService.GetAdminByIdAsync(id);

        if (result == null)
        {
            return NotFound(new { message = "Refund request not found" });
        }

        return Ok(result);
    }

    [HttpPut("{id:int}/approve")]
    public async Task<IActionResult> Approve(int id, [FromBody] ReviewRefundRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        try
        {
            var result = await _refundRequestService.ApproveAsync(id, adminUserId, dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase)
                ? NotFound(new { message = ex.Message })
                : BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/reject")]
    public async Task<IActionResult> Reject(int id, [FromBody] ReviewRefundRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        try
        {
            var result = await _refundRequestService.RejectAsync(id, adminUserId, dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase)
                ? NotFound(new { message = ex.Message })
                : BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("{id:int}/mark-refunded")]
    public async Task<IActionResult> MarkRefunded(int id, [FromBody] ReviewRefundRequestDto dto)
    {
        if (!TryGetUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        try
        {
            var result = await _refundRequestService.MarkRefundedAsync(id, adminUserId, dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return ex.Message.Contains("not found", StringComparison.OrdinalIgnoreCase)
                ? NotFound(new { message = ex.Message })
                : BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId);
    }
}
