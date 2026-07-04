using AdidasShoesStore.Api.Services.Interfaces;

namespace AdidasShoesStore.Api.Helpers;

public static class NotificationDispatch
{
    public static async Task TryAsync(
        INotificationService notificationService,
        ILogger logger,
        Func<INotificationService, Task> action)
    {
        try
        {
            await action(notificationService);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Notification dispatch failed");
        }
    }
}
