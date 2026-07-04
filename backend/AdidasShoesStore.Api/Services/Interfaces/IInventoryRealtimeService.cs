namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IInventoryRealtimeService
{
    Task NotifyStockChangedAsync(int productId, int variantId, string? reason = null);

    Task NotifyStockChangedAsync(IEnumerable<(int ProductId, int VariantId)> variants, string? reason = null);
}
