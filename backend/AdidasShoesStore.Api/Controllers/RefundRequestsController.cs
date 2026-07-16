using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.RefundRequests;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/refund-requests")]
public class RefundRequestsController : ControllerBase
{
    private readonly IRefundRequestService _refundRequestService;

    public RefundRequestsController(IRefundRequestService refundRequestService)
    {
        _refundRequestService = refundRequestService;
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRefundRequestDto dto)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _refundRequestService.CreateAsync(userId, dto);

        if (result == null)
        {
            return BadRequest(new
            {
                message = "Unable to create refund request. Check order status, payment status, shipment status, and amount."
            });
        }

        return Ok(result);
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyRequests()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _refundRequestService.GetMyAsync(userId);
        return Ok(result);
    }

    [HttpGet("my/{id:int}")]
    public async Task<IActionResult> GetMyRequestById(int id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _refundRequestService.GetMyByIdAsync(userId, id);

        if (result == null)
        {
            return NotFound(new { message = "Refund request not found" });
        }

        return Ok(result);
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId);
    }
}
