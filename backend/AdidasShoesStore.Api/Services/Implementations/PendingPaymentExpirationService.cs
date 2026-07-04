using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Services.Implementations;

public class PendingPaymentExpirationService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<PendingPaymentExpirationService> _logger;
    private readonly PaymentSettings _settings;

    public PendingPaymentExpirationService(
        IServiceScopeFactory scopeFactory,
        IOptions<PaymentSettings> options,
        ILogger<PendingPaymentExpirationService> logger)
    {
        _scopeFactory = scopeFactory;
        _settings = options.Value;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await ExpirePendingPaymentsAsync(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Pending payment expiration job failed");
            }

            var intervalMinutes = Math.Max(1, _settings.ExpirationScanIntervalMinutes);
            await Task.Delay(TimeSpan.FromMinutes(intervalMinutes), stoppingToken);
        }
    }

    private async Task ExpirePendingPaymentsAsync(CancellationToken cancellationToken)
    {
        var expireMinutes = Math.Max(1, _settings.PendingPaymentExpireMinutes);
        var cutoff = DateTime.Now.AddMinutes(-expireMinutes);

        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AdidasShoesStoreContext>();
        var inventoryRealtimeService = scope.ServiceProvider.GetRequiredService<IInventoryRealtimeService>();

        var orders = await context.Orders
            .Include(o => o.Payment)
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.Variant)
            .Where(o =>
                o.Status == "PendingPayment" &&
                o.CreatedAt != null &&
                o.CreatedAt <= cutoff &&
                o.Payment != null &&
                o.Payment.Status == "Pending")
            .ToListAsync(cancellationToken);

        foreach (var order in orders)
        {
            await using var transaction = await context.Database.BeginTransactionAsync(cancellationToken);

            try
            {
                await context.Entry(order).ReloadAsync(cancellationToken);
                await context.Entry(order).Reference(o => o.Payment).LoadAsync(cancellationToken);
                await context.Entry(order).Collection(o => o.OrderItems).LoadAsync(cancellationToken);

                if (order.Status != "PendingPayment" ||
                    order.Payment == null ||
                    order.Payment.Status != "Pending")
                {
                    await transaction.RollbackAsync(cancellationToken);
                    continue;
                }

                var restoredVariants = new List<(int ProductId, int VariantId)>();
                foreach (var item in order.OrderItems)
                {
                    await context.Entry(item).Reference(i => i.Variant).LoadAsync(cancellationToken);

                    if (item.Variant != null)
                    {
                        item.Variant.StockQuantity = (item.Variant.StockQuantity ?? 0) + item.Quantity;
                        restoredVariants.Add((item.Variant.ProductId, item.Variant.VariantId));
                    }
                }

                order.Status = "Failed";
                order.Note = AppendNote(order.Note, "Payment expired");
                order.Payment.Status = "Failed";
                order.Payment.RawWebhookData ??= "Payment expired";

                await context.SaveChangesAsync(cancellationToken);
                await transaction.CommitAsync(cancellationToken);

                await inventoryRealtimeService.NotifyStockChangedAsync(restoredVariants, "PaymentExpired");

                var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();
                await NotificationDispatch.TryAsync(
                    notificationService,
                    _logger,
                    async service =>
                    {
                        await service.CreateForUserAsync(
                            order.UserId,
                            "Payment expired",
                            $"Payment for order {order.OrderCode} was not completed.",
                            NotificationTypes.PaymentExpired,
                            relatedOrderId: order.OrderId,
                            relatedPaymentId: order.Payment?.PaymentId);

                        await service.CreateForRoleAsync(
                            "Admin",
                            "Payment expired",
                            $"Payment for order {order.OrderCode} was not completed.",
                            NotificationTypes.PaymentExpired,
                            relatedOrderId: order.OrderId,
                            relatedPaymentId: order.Payment?.PaymentId);
                    });

                _logger.LogInformation("Expired pending payment order {OrderCode}", order.OrderCode);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync(cancellationToken);
                _logger.LogError(ex, "Could not expire pending payment order {OrderCode}", order.OrderCode);
            }
        }
    }

    private static string AppendNote(string? note, string value)
    {
        if (string.IsNullOrWhiteSpace(note))
        {
            return value;
        }

        if (note.Contains(value, StringComparison.OrdinalIgnoreCase))
        {
            return note;
        }

        var combined = $"{note}; {value}";
        return combined.Length <= 255 ? combined : combined[..255];
    }
}
