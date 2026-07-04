using AdidasShoesStore.Api.DTOs.Notifications;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface INotificationService
{
    Task<NotificationDto?> CreateForUserAsync(
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
        string? metadataJson = null);

    Task<NotificationDto?> CreateForRoleAsync(
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
        string? metadataJson = null);

    Task<BroadcastNotificationResultDto> BroadcastToRoleAsync(
        string role,
        string title,
        string message,
        string type,
        int? relatedProductId = null,
        string? actionUrl = null,
        string? metadataJson = null);

    Task<NotificationListDto> GetMyNotificationsAsync(
        int currentUserId,
        string currentRole,
        int page = 1,
        int pageSize = 20);

    Task<int> GetUnreadCountAsync(int currentUserId, string currentRole);

    Task<bool> MarkAsReadAsync(int notificationId, int currentUserId, string currentRole);

    Task<int> MarkAllAsReadAsync(int currentUserId, string currentRole);

    Task<NotificationListDto> GetAdminNotificationsAsync(
        int currentAdminUserId,
        int page = 1,
        int pageSize = 20);
}
