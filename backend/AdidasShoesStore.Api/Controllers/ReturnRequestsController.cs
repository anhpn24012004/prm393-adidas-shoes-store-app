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

    public ReturnRequestsController(IReturnRequestService returnRequestService)
    {
        _returnRequestService = returnRequestService;
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
