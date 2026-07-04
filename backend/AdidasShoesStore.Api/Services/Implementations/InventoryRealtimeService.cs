using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Inventory;
using AdidasShoesStore.Api.Hubs;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class InventoryRealtimeService : IInventoryRealtimeService
{
    private readonly AdidasShoesStoreContext _context;
    private readonly IHubContext<InventoryHub> _hubContext;
    private readonly ILogger<InventoryRealtimeService> _logger;

    public InventoryRealtimeService(
        AdidasShoesStoreContext context,
        IHubContext<InventoryHub> hubContext,
        ILogger<InventoryRealtimeService> logger)
    {
        _context = context;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task NotifyStockChangedAsync(int productId, int variantId, string? reason = null)
    {
        var variant = await _context.ProductVariants
            .AsNoTracking()
            .Where(v => v.VariantId == variantId)
            .Select(v => new
            {
                v.ProductId,
                v.VariantId,
                StockQuantity = v.StockQuantity ?? 0
            })
            .FirstOrDefaultAsync();

        var effectiveProductId = variant?.ProductId ?? productId;
        var stockQuantity = variant?.StockQuantity ?? 0;
        var totalStock = await _context.ProductVariants
            .AsNoTracking()
            .Where(v => v.ProductId == effectiveProductId && v.IsActive == true)
            .SumAsync(v => v.StockQuantity ?? 0);

        var payload = new StockChangedDto
        {
            ProductId = effectiveProductId,
            VariantId = variant?.VariantId ?? variantId,
            StockQuantity = stockQuantity,
            TotalStock = totalStock,
            IsInStock = stockQuantity > 0,
            UpdatedAt = DateTime.UtcNow,
            Reason = reason
        };

        try
        {
            await _hubContext.Clients.All.SendAsync("StockChanged", payload);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(
                ex,
                "Could not broadcast stock change for ProductId={ProductId}, VariantId={VariantId}",
                effectiveProductId,
                variantId);
        }
    }

    public async Task NotifyStockChangedAsync(
        IEnumerable<(int ProductId, int VariantId)> variants,
        string? reason = null)
    {
        var distinctVariants = variants
            .GroupBy(item => item.VariantId)
            .Select(group => group.First())
            .ToList();

        foreach (var variant in distinctVariants)
        {
            await NotifyStockChangedAsync(variant.ProductId, variant.VariantId, reason);
        }
    }
}
