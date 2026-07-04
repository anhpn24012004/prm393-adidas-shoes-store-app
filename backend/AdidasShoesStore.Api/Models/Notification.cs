using System;

namespace AdidasShoesStore.Api.Models;

public partial class Notification
{
    public int NotificationId { get; set; }

    public int? UserId { get; set; }

    public string? Role { get; set; }

    public string Title { get; set; } = null!;

    public string Message { get; set; } = null!;

    public string Type { get; set; } = null!;

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

    public virtual User? User { get; set; }

    public virtual ICollection<NotificationRecipient> Recipients { get; set; } = new List<NotificationRecipient>();
}
