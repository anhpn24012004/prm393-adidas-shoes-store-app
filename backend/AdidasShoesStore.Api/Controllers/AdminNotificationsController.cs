using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.DTOs.Notifications;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AdidasShoesStore.Api.Controllers;

[Authorize(Roles = "Admin")]
[ApiController]
[Route("api/admin/notifications")]
public class AdminNotificationsController : ControllerBase
{
    private static readonly HashSet<string> AllowedBroadcastTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        NotificationTypes.Deal,
        NotificationTypes.Discount,
        NotificationTypes.FlashSale,
        NotificationTypes.Voucher
    };

    private static readonly HashSet<string> AllowedTargetRoles = new(StringComparer.OrdinalIgnoreCase)
    {
        "Customer",
        "Admin"
    };

    private readonly INotificationService _notificationService;

    public AdminNotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet]
    public async Task<IActionResult> GetNotifications(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        if (!TryGetAdminUserId(out var adminUserId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _notificationService.GetAdminNotificationsAsync(adminUserId, page, pageSize);
        return Ok(result);
    }

    [HttpPost("broadcast")]
    public async Task<IActionResult> Broadcast([FromBody] BroadcastNotificationDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Title) ||
            string.IsNullOrWhiteSpace(dto.Message) ||
            string.IsNullOrWhiteSpace(dto.Type))
        {
            return BadRequest(new { message = "Title, message, and type are required." });
        }

        if (!AllowedBroadcastTypes.Contains(dto.Type.Trim()))
        {
            return BadRequest(new { message = "Invalid marketing notification type." });
        }

        var targetRole = string.IsNullOrWhiteSpace(dto.TargetRole)
            ? "Customer"
            : dto.TargetRole.Trim();

        if (!AllowedTargetRoles.Contains(targetRole))
        {
            return BadRequest(new { message = "Invalid target role." });
        }

        var result = await _notificationService.BroadcastToRoleAsync(
            targetRole,
            dto.Title.Trim(),
            dto.Message.Trim(),
            dto.Type.Trim(),
            dto.RelatedProductId,
            dto.ActionUrl);

        if (!result.Success)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    private bool TryGetAdminUserId(out int userId)
    {
        userId = 0;
        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId);
    }
}
