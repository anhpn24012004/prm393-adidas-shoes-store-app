using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Services.Implementations;

public class GhnShipmentSyncService : BackgroundService
{
    private static readonly string[] FinalStatuses = { "Delivered", "Returned", "Cancelled" };

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly GhnSyncSettings _settings;
    private readonly ILogger<GhnShipmentSyncService> _logger;

    public GhnShipmentSyncService(
        IServiceScopeFactory scopeFactory,
        IOptions<GhnSyncSettings> options,
        ILogger<GhnShipmentSyncService> logger)
    {
        _scopeFactory = scopeFactory;
        _settings = options.Value;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            if (_settings.Enabled)
            {
                try
                {
                    await SyncShipmentsAsync(stoppingToken);
                }
                catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "GHN shipment sync job failed");
                }
            }

            var intervalMinutes = Math.Max(5, _settings.IntervalMinutes);
            await Task.Delay(TimeSpan.FromMinutes(intervalMinutes), stoppingToken);
        }
    }

    private async Task SyncShipmentsAsync(CancellationToken cancellationToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AdidasShoesStoreContext>();
        var ghnService = scope.ServiceProvider.GetRequiredService<IGhnService>();
        var emailService = scope.ServiceProvider.GetRequiredService<IEmailService>();

        var shipments = await context.Shipments
            .AsNoTracking()
            .Where(s =>
                s.GhnOrderCode != null &&
                s.GhnOrderCode != "" &&
                (s.Status == null || !FinalStatuses.Contains(s.Status)))
            .Select(s => new
            {
                s.ShipmentId,
                s.GhnOrderCode
            })
            .ToListAsync(cancellationToken);

        foreach (var item in shipments)
        {
            try
            {
                var tracking = await ghnService.GetTrackingAsync(item.GhnOrderCode!);
                if (!tracking.Success || tracking.Data == null)
                {
                    _logger.LogWarning(
                        "Could not sync GHN shipment {ShipmentId} with order code {GhnOrderCode}: {Message}",
                        item.ShipmentId,
                        item.GhnOrderCode,
                        tracking.Message);
                    continue;
                }

                await ApplyTrackingAsync(
                    context,
                    emailService,
                    scope.ServiceProvider.GetRequiredService<INotificationService>(),
                    item.ShipmentId,
                    tracking.Data.Status,
                    tracking.Data.RawStatus,
                    tracking.Data.LeadTime,
                    cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    ex,
                    "Could not sync GHN shipment {ShipmentId} with order code {GhnOrderCode}",
                    item.ShipmentId,
                    item.GhnOrderCode);
            }
        }
    }

    private async Task ApplyTrackingAsync(
        AdidasShoesStoreContext context,
        IEmailService emailService,
        INotificationService notificationService,
        int shipmentId,
        string? newStatus,
        string? rawStatus,
        DateTime? leadTime,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(newStatus))
        {
            return;
        }

        var shipment = await context.Shipments
            .Include(s => s.Order)
                .ThenInclude(o => o.Payment)
            .Include(s => s.Order)
                .ThenInclude(o => o.User)
            .FirstOrDefaultAsync(s => s.ShipmentId == shipmentId, cancellationToken);

        if (shipment == null ||
            FinalStatuses.Contains(shipment.Status ?? string.Empty))
        {
            return;
        }

        var shouldSendCodInvoice = false;
        var changed = !string.Equals(shipment.Status, newStatus, StringComparison.Ordinal) ||
            !string.Equals(shipment.RawGhnStatus, rawStatus, StringComparison.Ordinal) ||
            shipment.ExpectedDeliveryTime != leadTime;

        if (IsBackwardTransition(shipment.Status, newStatus))
        {
            _logger.LogWarning(
                "Ignored backward GHN shipment status update for shipment {ShipmentId}: {CurrentStatus} -> {NewStatus}",
                shipmentId,
                shipment.Status,
                newStatus
            );
            return;
        }

        var previousStatus = shipment.Status;
        shipment.Status = newStatus;
        shipment.RawGhnStatus = rawStatus;
        shipment.ExpectedDeliveryTime = leadTime ?? shipment.ExpectedDeliveryTime;

        if (newStatus is "ReadyToPick" or "Picking" or "Shipped" or "InTransit" or "OutForDelivery")
        {
            if (shipment.Order.Status != "Shipping")
            {
                shipment.Order.Status = "Shipping";
                changed = true;
            }
        }
        else if (newStatus == "Delivered")
        {
            if (shipment.DeliveredAt == null)
            {
                shipment.DeliveredAt = DateTime.Now;
                changed = true;
            }

            if (shipment.Order.Status != "Delivered")
            {
                shipment.Order.Status = "Delivered";
                changed = true;
            }

            if (MarkCodPaymentSuccess(shipment.Order))
            {
                shouldSendCodInvoice = true;
            }
        }
        else if (newStatus == "Returned")
        {
            if (shipment.Order.Status != "Cancelled")
            {
                shipment.Order.Status = "Cancelled";
                changed = true;
            }
        }

        if (!changed && !shouldSendCodInvoice)
        {
            return;
        }

        await context.SaveChangesAsync(cancellationToken);

        await NotifyShipmentStatusChangeAsync(
            notificationService,
            shipment,
            previousStatus,
            shipment.Status ?? newStatus);

        if (shouldSendCodInvoice)
        {
            try
            {
                await emailService.SendInvoiceEmailAsync(shipment.Order);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not send COD invoice for order {OrderCode}", shipment.Order.OrderCode);
            }
        }
    }

    private static bool MarkCodPaymentSuccess(Order order)
    {
        if (order.Payment == null ||
            !string.Equals(order.Payment.PaymentMethod, "COD", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(order.Payment.Status, "Success", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        order.Payment.Status = "Success";
        order.Payment.PaidAt = DateTime.Now;
        order.Payment.TransactionCode = $"COD-{order.OrderCode}";

        return true;
    }

    private static bool IsBackwardTransition(string? currentStatus, string newStatus)
    {
        if (newStatus is "Failed" or "Returned")
        {
            return false;
        }

        var currentRank = GetShipmentStatusRank(currentStatus);
        var newRank = GetShipmentStatusRank(newStatus);

        return currentRank.HasValue &&
               newRank.HasValue &&
               newRank.Value < currentRank.Value;
    }

    private static int? GetShipmentStatusRank(string? status)
    {
        return status switch
        {
            "ReadyToPick" => 0,
            "Picking" => 1,
            "Shipped" => 2,
            "InTransit" => 3,
            "OutForDelivery" => 4,
            "Delivered" => 5,
            _ => null
        };
    }

    private Task NotifyShipmentStatusChangeAsync(
        INotificationService notificationService,
        Shipment shipment,
        string? previousStatus,
        string newStatus)
    {
        if (string.Equals(previousStatus, newStatus, StringComparison.Ordinal))
        {
            return Task.CompletedTask;
        }

        var order = shipment.Order;
        var orderCode = order.OrderCode;

        if (newStatus is "Picking" or "Shipped" or "InTransit" or "OutForDelivery")
        {
            return NotificationDispatch.TryAsync(
                notificationService,
                _logger,
                service => service.CreateForUserAsync(
                    order.UserId,
                    "Order is on the way",
                    $"Your order {orderCode} is being shipped.",
                    NotificationTypes.Shipping,
                    relatedOrderId: order.OrderId,
                    relatedShipmentId: shipment.ShipmentId));
        }

        if (newStatus == "Delivered")
        {
            return NotificationDispatch.TryAsync(
                notificationService,
                _logger,
                service => service.CreateForUserAsync(
                    order.UserId,
                    "Order delivered",
                    $"Your order {orderCode} has been delivered.",
                    NotificationTypes.Delivered,
                    relatedOrderId: order.OrderId,
                    relatedShipmentId: shipment.ShipmentId));
        }

        return Task.CompletedTask;
    }
}
