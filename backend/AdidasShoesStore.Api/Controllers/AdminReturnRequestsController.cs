using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.Returns;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Authorize(Roles = "Admin")]
[ApiController]
[Route("api/admin/return-requests")]
public class AdminReturnRequestsController : ControllerBase
{
    private readonly IReturnRequestService _returnRequestService;

    public AdminReturnRequestsController(IReturnRequestService returnRequestService)
    {
        _returnRequestService = returnRequestService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _returnRequestService.GetAllAsync());
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _returnRequestService.GetByIdAsync(id);
        return result == null ? NotFound(new { message = "Return request not found" }) : Ok(result);
    }

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
