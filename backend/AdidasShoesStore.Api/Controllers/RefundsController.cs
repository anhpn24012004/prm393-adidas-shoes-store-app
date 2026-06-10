using AdidasShoesStore.Api.DTOs.Refunds;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class RefundsController : ControllerBase
{
    private readonly IRefundService _refundService;

    public RefundsController(IRefundService refundService)
    {
        _refundService = refundService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await _refundService.GetAllAsync();
        return Ok(result);
    }

    [HttpGet("order/{orderId}")]
    public async Task<IActionResult> GetByOrderId(int orderId)
    {
        var result = await _refundService.GetByOrderIdAsync(orderId);
        return Ok(result);
    }

    [HttpGet("return-request/{returnRequestId}")]
    public async Task<IActionResult> GetByReturnRequestId(int returnRequestId)
    {
        var result = await _refundService.GetByReturnRequestIdAsync(returnRequestId);

        if (result == null)
            return NotFound("Refund not found.");

        return Ok(result);
    }

    [HttpPut("{id}/complete")]
    public async Task<IActionResult> CompleteRefund(
        int id,
        [FromBody] CompleteRefundDto dto)
    {
        var success = await _refundService.CompleteRefundAsync(id, dto);

        if (!success)
            return BadRequest("Cannot complete this refund.");

        return Ok("Refund completed successfully.");
    }
}