using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Notifications;
using AdidasShoesStore.Api.Hubs;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class NotificationService : INotificationService
{
    private static readonly TimeSpan DuplicateWindow = TimeSpan.FromMinutes(3);

    private readonly AdidasShoesStoreContext _context;
    private readonly IHubContext<NotificationHub> _hubContext;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        AdidasShoesStoreContext context,
        IHubContext<NotificationHub> hubContext,
        ILogger<NotificationService> logger)
    {
        _context = context;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task<NotificationDto?> CreateForUserAsync(
        int userId,
        string title,
        string message,
        string type,
        int? relatedOrderId = null,
        int? relatedPaymentId = null,
        int? relatedShipmentId = null,
        int? relatedRefundRequestId = null,
        int? relatedReturnRequestId = null,
        int? relatedProductId = null,
        string? actionUrl = null,
        string? metadataJson = null)
    {
        var result = await CreateAsync(
            userId,
            null,
            new[] { userId },
            title,
            message,
            type,
            relatedOrderId,
            relatedPaymentId,
            relatedShipmentId,
            relatedRefundRequestId,
            relatedReturnRequestId,
            relatedProductId,
            actionUrl,
            metadataJson);

        return result.Notification;
    }

    public async Task<NotificationDto?> CreateForRoleAsync(
        string role,
        string title,
        string message,
        string type,
        int? relatedOrderId = null,
        int? relatedPaymentId = null,
        int? relatedShipmentId = null,
        int? relatedRefundRequestId = null,
        int? relatedReturnRequestId = null,
        int? relatedProductId = null,
        string? actionUrl = null,
        string? metadataJson = null)
    {
        var recipientIds = await GetActiveUserIdsByRoleAsync(role);
        var result = await CreateAsync(
            null,
            role,
            recipientIds,
            title,
            message,
            type,
            relatedOrderId,
            relatedPaymentId,
            relatedShipmentId,
            relatedRefundRequestId,
            relatedReturnRequestId,
            relatedProductId,
            actionUrl,
            metadataJson);

        return result.Notification;
    }

    public async Task<BroadcastNotificationResultDto> BroadcastToRoleAsync(
        string role,
        string title,
        string message,
        string type,
        int? relatedProductId = null,
        string? actionUrl = null,
        string? metadataJson = null)
    {
        var recipientIds = await GetActiveUserIdsByRoleAsync(role);
        var result = await CreateAsync(
            null,
            role,
            recipientIds,
            title,
            message,
            type,
            relatedProductId: relatedProductId,
            actionUrl: actionUrl,
            metadataJson: metadataJson);

        if (result.Notification == null)
        {
            return new BroadcastNotificationResultDto
            {
                Success = false,
                Message = result.Message,
                TotalRecipients = result.TotalRecipients
            };
        }

        return new BroadcastNotificationResultDto
        {
            Success = true,
            Message = "Notification broadcast successfully.",
            NotificationId = result.Notification.NotificationId,
            TotalRecipients = result.TotalRecipients
        };
    }

    public async Task<NotificationListDto> GetMyNotificationsAsync(
        int currentUserId,
        string currentRole,
        int page = 1,
        int pageSize = 20)
    {
        page = page < 1 ? 1 : page;
        pageSize = pageSize < 1 ? 20 : Math.Min(pageSize, 100);

        var query = BuildVisibleDtoQuery(currentUserId, currentRole);
        var totalCount = await query.CountAsync();
        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new NotificationListDto
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<int> GetUnreadCountAsync(int currentUserId, string currentRole)
    {
        return await BuildVisibleDtoQuery(currentUserId, currentRole)
            .CountAsync(n => !n.IsRead);
    }

    public async Task<bool> MarkAsReadAsync(
        int notificationId,
        int currentUserId,
        string currentRole)
    {
        var recipient = await _context.NotificationRecipients
            .FirstOrDefaultAsync(r =>
                r.NotificationId == notificationId &&
                r.UserId == currentUserId);

        if (recipient != null)
        {
            if (!recipient.IsRead)
            {
                recipient.IsRead = true;
                recipient.ReadAt = DateTime.Now;
                await _context.SaveChangesAsync();
                await PushUnreadCountAsync(currentUserId, currentRole);
            }

            return true;
        }

        var legacyNotification = await BuildLegacyVisibleQuery(currentUserId, currentRole)
            .FirstOrDefaultAsync(n => n.NotificationId == notificationId);

        if (legacyNotification == null)
        {
            return false;
        }

        if (!legacyNotification.IsRead)
        {
            legacyNotification.IsRead = true;
            legacyNotification.ReadAt = DateTime.Now;
            await _context.SaveChangesAsync();
            await PushUnreadCountAsync(currentUserId, currentRole);
        }

        return true;
    }

    public async Task<int> MarkAllAsReadAsync(int currentUserId, string currentRole)
    {
        var unreadRecipients = await _context.NotificationRecipients
            .Where(r => r.UserId == currentUserId && !r.IsRead)
            .ToListAsync();

        var legacyNotifications = await BuildLegacyVisibleQuery(currentUserId, currentRole)
            .Where(n => !n.IsRead)
            .ToListAsync();

        if (unreadRecipients.Count == 0 && legacyNotifications.Count == 0)
        {
            return 0;
        }

        var now = DateTime.Now;
        foreach (var recipient in unreadRecipients)
        {
            recipient.IsRead = true;
            recipient.ReadAt = now;
        }

        foreach (var notification in legacyNotifications)
        {
            notification.IsRead = true;
            notification.ReadAt = now;
        }

        await _context.SaveChangesAsync();
        await PushUnreadCountAsync(currentUserId, currentRole);

        return unreadRecipients.Count + legacyNotifications.Count;
    }

    public Task<NotificationListDto> GetAdminNotificationsAsync(
        int currentAdminUserId,
        int page = 1,
        int pageSize = 20)
    {
        return GetMyNotificationsAsync(currentAdminUserId, "Admin", page, pageSize);
    }

    private async Task<(NotificationDto? Notification, int TotalRecipients, string Message)> CreateAsync(
        int? userId,
        string? role,
        IEnumerable<int> recipientUserIds,
        string title,
        string message,
        string type,
        int? relatedOrderId = null,
        int? relatedPaymentId = null,
        int? relatedShipmentId = null,
        int? relatedRefundRequestId = null,
        int? relatedReturnRequestId = null,
        int? relatedProductId = null,
        string? actionUrl = null,
        string? metadataJson = null)
    {
        title = title.Trim();
        message = message.Trim();
        type = type.Trim();
        role = string.IsNullOrWhiteSpace(role) ? null : role.Trim();

        if (string.IsNullOrWhiteSpace(title) ||
            string.IsNullOrWhiteSpace(message) ||
            string.IsNullOrWhiteSpace(type))
        {
            return (null, 0, "Title, message, and type are required.");
        }

        var recipients = recipientUserIds.Distinct().ToList();
        if (recipients.Count == 0)
        {
            return (null, 0, "No recipients found.");
        }

        if (await IsDuplicateAsync(
                userId,
                role,
                title,
                message,
                type,
                relatedOrderId,
                relatedPaymentId,
                relatedShipmentId,
                relatedRefundRequestId,
                relatedReturnRequestId,
                relatedProductId))
        {
            return (null, recipients.Count, "Duplicate notification ignored.");
        }

        var now = DateTime.Now;
        var notification = new Notification
        {
            UserId = userId,
            Role = role,
            Title = title,
            Message = message,
            Type = type,
            IsRead = false,
            CreatedAt = now,
            RelatedOrderId = relatedOrderId,
            RelatedPaymentId = relatedPaymentId,
            RelatedShipmentId = relatedShipmentId,
            RelatedRefundRequestId = relatedRefundRequestId,
            RelatedReturnRequestId = relatedReturnRequestId,
            RelatedProductId = relatedProductId,
            ActionUrl = string.IsNullOrWhiteSpace(actionUrl) ? null : actionUrl.Trim(),
            MetadataJson = string.IsNullOrWhiteSpace(metadataJson) ? null : metadataJson.Trim()
        };

        foreach (var recipientId in recipients)
        {
            notification.Recipients.Add(new NotificationRecipient
            {
                UserId = recipientId,
                IsRead = false,
                CreatedAt = now
            });
        }

        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();

        var dto = Map(notification, false, null);
        await PushNotificationAsync(dto, recipients);

        return (dto, recipients.Count, "Notification created.");
    }

    private IQueryable<NotificationDto> BuildVisibleDtoQuery(int currentUserId, string currentRole)
    {
        var normalizedRole = currentRole.Trim();

        var recipientQuery = _context.NotificationRecipients.AsNoTracking()
            .Where(r => r.UserId == currentUserId)
            .Select(r => new NotificationDto
            {
                NotificationId = r.Notification.NotificationId,
                UserId = r.Notification.UserId,
                Role = r.Notification.Role,
                Title = r.Notification.Title,
                Message = r.Notification.Message,
                Type = r.Notification.Type,
                IsRead = r.IsRead,
                CreatedAt = r.Notification.CreatedAt,
                ReadAt = r.ReadAt,
                RelatedOrderId = r.Notification.RelatedOrderId,
                RelatedPaymentId = r.Notification.RelatedPaymentId,
                RelatedShipmentId = r.Notification.RelatedShipmentId,
                RelatedRefundRequestId = r.Notification.RelatedRefundRequestId,
                RelatedReturnRequestId = r.Notification.RelatedReturnRequestId,
                RelatedProductId = r.Notification.RelatedProductId,
                ActionUrl = r.Notification.ActionUrl,
                MetadataJson = r.Notification.MetadataJson
            });

        return recipientQuery.Concat(BuildLegacyVisibleQuery(currentUserId, normalizedRole)
            .AsNoTracking()
            .Select(n => new NotificationDto
            {
                NotificationId = n.NotificationId,
                UserId = n.UserId,
                Role = n.Role,
                Title = n.Title,
                Message = n.Message,
                Type = n.Type,
                IsRead = n.IsRead,
                CreatedAt = n.CreatedAt,
                ReadAt = n.ReadAt,
                RelatedOrderId = n.RelatedOrderId,
                RelatedPaymentId = n.RelatedPaymentId,
                RelatedShipmentId = n.RelatedShipmentId,
                RelatedRefundRequestId = n.RelatedRefundRequestId,
                RelatedReturnRequestId = n.RelatedReturnRequestId,
                RelatedProductId = n.RelatedProductId,
                ActionUrl = n.ActionUrl,
                MetadataJson = n.MetadataJson
            }));
    }

    private IQueryable<Notification> BuildLegacyVisibleQuery(int currentUserId, string currentRole)
    {
        var normalizedRole = currentRole.Trim();

        return _context.Notifications.Where(n =>
            !n.Recipients.Any() &&
            ((n.UserId == currentUserId) ||
             (n.Role == normalizedRole && n.UserId == null)));
    }

    private async Task<List<int>> GetActiveUserIdsByRoleAsync(string role)
    {
        var normalizedRole = role.Trim();

        return await _context.Users.AsNoTracking()
            .Where(u =>
                u.IsActive != false &&
                u.Role.RoleName == normalizedRole)
            .Select(u => u.UserId)
            .ToListAsync();
    }

    private async Task<bool> IsDuplicateAsync(
        int? userId,
        string? role,
        string title,
        string message,
        string type,
        int? relatedOrderId,
        int? relatedPaymentId,
        int? relatedShipmentId,
        int? relatedRefundRequestId,
        int? relatedReturnRequestId,
        int? relatedProductId)
    {
        var cutoff = DateTime.Now.Subtract(DuplicateWindow);
        return await _context.Notifications.AsNoTracking()
            .Where(n =>
                n.CreatedAt >= cutoff &&
                n.UserId == userId &&
                n.Role == role &&
                n.Title == title &&
                n.Message == message &&
                n.Type == type &&
                n.RelatedOrderId == relatedOrderId &&
                n.RelatedPaymentId == relatedPaymentId &&
                n.RelatedShipmentId == relatedShipmentId &&
                n.RelatedRefundRequestId == relatedRefundRequestId &&
                n.RelatedReturnRequestId == relatedReturnRequestId &&
                n.RelatedProductId == relatedProductId)
            .AnyAsync();
    }

    private async Task PushNotificationAsync(NotificationDto dto, IReadOnlyCollection<int> recipientUserIds)
    {
        try
        {
            if (dto.UserId.HasValue)
            {
                await _hubContext.Clients
                    .Group($"user:{dto.UserId.Value}")
                    .SendAsync("NotificationReceived", dto);

                var userRole = await _context.Users.AsNoTracking()
                    .Where(u => u.UserId == dto.UserId.Value)
                    .Select(u => u.Role.RoleName)
                    .FirstOrDefaultAsync();

                if (!string.IsNullOrWhiteSpace(userRole))
                {
                    await PushUnreadCountAsync(dto.UserId.Value, userRole);
                }

                return;
            }

            if (!string.IsNullOrWhiteSpace(dto.Role))
            {
                await _hubContext.Clients
                    .Group($"role:{dto.Role}")
                    .SendAsync("NotificationReceived", dto);
            }

            foreach (var userId in recipientUserIds)
            {
                await PushUnreadCountAsync(userId, dto.Role ?? string.Empty);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to push realtime notification {NotificationId}", dto.NotificationId);
        }
    }

    private async Task PushUnreadCountAsync(int currentUserId, string currentRole)
    {
        try
        {
            var count = await GetUnreadCountAsync(currentUserId, currentRole);
            await _hubContext.Clients
                .Group($"user:{currentUserId}")
                .SendAsync("UnreadCountChanged", new UnreadCountDto { Count = count });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to push unread count for user {UserId}", currentUserId);
        }
    }

    private static NotificationDto Map(Notification notification, bool isRead, DateTime? readAt)
    {
        return new NotificationDto
        {
            NotificationId = notification.NotificationId,
            UserId = notification.UserId,
            Role = notification.Role,
            Title = notification.Title,
            Message = notification.Message,
            Type = notification.Type,
            IsRead = isRead,
            CreatedAt = notification.CreatedAt,
            ReadAt = readAt,
            RelatedOrderId = notification.RelatedOrderId,
            RelatedPaymentId = notification.RelatedPaymentId,
            RelatedShipmentId = notification.RelatedShipmentId,
            RelatedRefundRequestId = notification.RelatedRefundRequestId,
            RelatedReturnRequestId = notification.RelatedReturnRequestId,
            RelatedProductId = notification.RelatedProductId,
            ActionUrl = notification.ActionUrl,
            MetadataJson = notification.MetadataJson
        };
    }
}
