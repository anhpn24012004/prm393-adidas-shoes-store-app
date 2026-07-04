namespace AdidasShoesStore.Api.Models;

public partial class NotificationRecipient
{
    public int NotificationRecipientId { get; set; }

    public int NotificationId { get; set; }

    public int UserId { get; set; }

    public bool IsRead { get; set; }

    public DateTime? ReadAt { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Notification Notification { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
