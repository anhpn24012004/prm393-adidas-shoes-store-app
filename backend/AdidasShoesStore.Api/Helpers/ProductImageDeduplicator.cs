using AdidasShoesStore.Api.DTOs.Products;

namespace AdidasShoesStore.Api.Helpers;

public static class ProductImageDeduplicator
{
    public static List<ProductImageDto> GetUniqueImages(
        IEnumerable<ProductImageDto> images)
    {
        return images
            .Where(image => !string.IsNullOrWhiteSpace(image.ImageUrl))
            .GroupBy(
                image => image.ImageUrl.Trim(),
                StringComparer.OrdinalIgnoreCase)
            .Select(group => group
                .OrderByDescending(image => image.IsMain)
                .ThenBy(image => image.ImageId)
                .First())
            .OrderByDescending(image => image.IsMain)
            .ThenBy(image => image.ImageId)
            .ToList();
    }
}
