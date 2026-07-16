using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.Notifications;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/notifications")]
public class NotificationsController : ControllerBase
{
    private readonly INotificationService _notificationService;

    public NotificationsController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMyNotifications(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        if (!TryGetUserContext(out var userId, out var role))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var result = await _notificationService.GetMyNotificationsAsync(userId, role, page, pageSize);
        return Ok(result);
    }

    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        if (!TryGetUserContext(out var userId, out var role))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var count = await _notificationService.GetUnreadCountAsync(userId, role);
        return Ok(new UnreadCountDto { Count = count });
    }

    [HttpPost("{id:int}/read")]
    public async Task<IActionResult> MarkAsRead(int id)
    {
        if (!TryGetUserContext(out var userId, out var role))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var updated = await _notificationService.MarkAsReadAsync(id, userId, role);
        if (!updated)
        {
            return NotFound(new { message = "Notification not found" });
        }

        return Ok(new { message = "Notification marked as read" });
    }

    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        if (!TryGetUserContext(out var userId, out var role))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var updatedCount = await _notificationService.MarkAllAsReadAsync(userId, role);
        return Ok(new { message = "All notifications marked as read", updatedCount });
    }

    private bool TryGetUserContext(out int userId, out string role)
    {
        userId = 0;
        role = User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;

        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId) && !string.IsNullOrWhiteSpace(role);
    }
}
