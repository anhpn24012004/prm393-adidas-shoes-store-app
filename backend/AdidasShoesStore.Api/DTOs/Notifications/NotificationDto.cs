namespace AdidasShoesStore.Api.DTOs.Notifications;

public class NotificationDto
{
    public int NotificationId { get; set; }
    public int? UserId { get; set; }
    public string? Role { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ReadAt { get; set; }
    public int? RelatedOrderId { get; set; }
    public int? RelatedPaymentId { get; set; }
    public int? RelatedShipmentId { get; set; }
    public int? RelatedRefundRequestId { get; set; }
    public int? RelatedReturnRequestId { get; set; }
    public int? RelatedProductId { get; set; }
    public string? ActionUrl { get; set; }
    public string? MetadataJson { get; set; }
}

public class NotificationListDto
{
    public List<NotificationDto> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}

public class BroadcastNotificationDto
{
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty;
    public string? TargetRole { get; set; }
    public int? RelatedProductId { get; set; }
    public string? ActionUrl { get; set; }
}

public class UnreadCountDto
{
    public int Count { get; set; }
}

public class BroadcastNotificationResultDto
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int? NotificationId { get; set; }
    public int TotalRecipients { get; set; }
}
