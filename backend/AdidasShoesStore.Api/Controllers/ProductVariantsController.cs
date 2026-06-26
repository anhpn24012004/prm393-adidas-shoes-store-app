using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using System.Text;
using System.Text.Json;

namespace AdidasShoesStore.Api.Controllers;

[Route("api")]
[ApiController]
public class ProductVariantsController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public ProductVariantsController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet("products/{productId}/variants")]
    public async Task<ActionResult<IEnumerable<ProductVariantDto>>> GetVariantsByProduct(int productId)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        var variants = await _context.ProductVariants
            .AsNoTracking()
            .Where(v => v.ProductId == productId)
            .Select(v => new ProductVariantDto
            {
                VariantId = v.VariantId,
                Size = v.Size,
                Color = v.Color,
                ImageUrl = v.ImageUrl,
                Price = v.Price,
                StockQuantity = v.StockQuantity ?? 0,
                Sku = v.Sku,
                IsActive = v.IsActive ?? false
            })
            .ToListAsync();

        return Ok(variants);
    }

    [HttpPost("products/{productId}/variants")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> CreateVariant(int productId, CreateProductVariantDto dto)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        var duplicateVariantExists = await _context.ProductVariants
            .AnyAsync(v =>
                v.ProductId == productId &&
                v.Size == dto.Size.Trim() &&
                v.Color == NormalizeColor(dto.Color));

        if (duplicateVariantExists)
        {
            return BadRequest(new { message = "Variant with this size and color already exists." });
        }

        var normalizedSku = NormalizeSku(dto.Sku);
        if (normalizedSku != null)
        {
            var skuExists = await _context.ProductVariants
                .AnyAsync(v => v.Sku == normalizedSku);

            if (skuExists)
            {
                return BadRequest(new { message = "SKU already exists on another variant." });
            }
        }

        var variant = new ProductVariant
        {
            ProductId = productId,
            Size = dto.Size.Trim(),
            Color = NormalizeColor(dto.Color),
            ImageUrl = NormalizeImageUrl(dto.ImageUrl),
            Price = dto.Price,
            StockQuantity = dto.StockQuantity,
            Sku = normalizedSku,
            IsActive = dto.IsActive
        };

        _context.ProductVariants.Add(variant);
        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException exception) when (IsUniqueConstraintViolation(exception))
        {
            return BadRequest(new { message = "SKU already exists on another variant." });
        }

        return Ok(new
        {
            message = "Product variant created successfully",
            variantId = variant.VariantId
        });
    }

    [HttpPut("productvariants/{variantId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateVariant(int variantId, UpdateProductVariantDto dto)
    {
        var variant = await _context.ProductVariants.FindAsync(variantId);

        if (variant == null)
        {
            return NotFound(new { message = "Product variant not found" });
        }

        var duplicateVariantExists = await _context.ProductVariants
            .AnyAsync(v =>
                v.ProductId == variant.ProductId &&
                v.VariantId != variantId &&
                v.Size == dto.Size.Trim() &&
                v.Color == NormalizeColor(dto.Color));

        if (duplicateVariantExists)
        {
            return BadRequest(new { message = "Variant with this size and color already exists." });
        }

        var normalizedSku = NormalizeSku(dto.Sku);
        if (normalizedSku != null)
        {
            var skuExists = await _context.ProductVariants
                .AnyAsync(v => v.Sku == normalizedSku && v.VariantId != variantId);

            if (skuExists)
            {
                return BadRequest(new { message = "SKU already exists on another variant." });
            }
        }

        variant.Size = dto.Size.Trim();
        variant.Color = NormalizeColor(dto.Color);
        variant.ImageUrl = NormalizeImageUrl(dto.ImageUrl);
        variant.Price = dto.Price;
        variant.StockQuantity = dto.StockQuantity;
        variant.Sku = normalizedSku;
        variant.IsActive = dto.IsActive;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (DbUpdateException exception) when (IsUniqueConstraintViolation(exception))
        {
            return BadRequest(new { message = "SKU already exists on another variant." });
        }

        return Ok(new { message = "Product variant updated successfully" });
    }

    [HttpDelete("productvariants/{variantId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteVariant(int variantId)
    {
        var variant = await _context.ProductVariants.FindAsync(variantId);

        if (variant == null)
        {
            return NotFound(new { message = "Product variant not found" });
        }

        variant.IsActive = false;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Product variant deleted successfully" });
    }

    private static string? NormalizeImageUrl(string? imageUrl)
    {
        return string.IsNullOrWhiteSpace(imageUrl) ? null : imageUrl.Trim();
    }

    private static string NormalizeColor(string? color)
    {
        return color?.Trim() ?? string.Empty;
    }

    private static string? NormalizeSku(string? sku)
    {
        return string.IsNullOrWhiteSpace(sku) ? null : sku.Trim();
    }

    [HttpGet("products/{productId}/classifications")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetProductClassifications(int productId)
    {
        var product = await _context.Products
            .AsNoTracking()
            .Include(p => p.ProductVariants)
            .FirstOrDefaultAsync(p => p.ProductId == productId);

        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        var groups = DeserializeGroups(product.ClassificationGroupsJson);
        if (groups.Count == 0)
        {
            groups = BuildLegacyGroups(product.ProductVariants);
        }

        var variants = product.ProductVariants
            .OrderBy(v => v.VariantId)
            .Select(v => new ProductVariantDto
            {
                VariantId = v.VariantId,
                Size = v.Size,
                Color = v.Color,
                ImageUrl = v.ImageUrl,
                OptionValues = GetOptionValues(v, groups),
                Price = v.Price,
                StockQuantity = v.StockQuantity ?? 0,
                Sku = v.Sku,
                IsActive = v.IsActive ?? false
            })
            .ToList();

        return Ok(new
        {
            classificationGroups = groups,
            variants
        });
    }

    [HttpPut("products/{productId}/classifications")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> SyncProductClassifications(
        int productId,
        SyncProductClassificationsDto dto)
    {
        var validationMessage = ValidateClassificationRequest(dto);
        if (validationMessage != null)
        {
            return BadRequest(new { message = validationMessage });
        }

        var product = await _context.Products
            .Include(p => p.ProductVariants)
            .FirstOrDefaultAsync(p => p.ProductId == productId);
        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        var requestSkus = dto.Variants
            .Select(v => NormalizeSku(v.Sku))
            .Where(sku => sku != null)
            .Cast<string>()
            .ToList();
        if (requestSkus.Count != requestSkus.Distinct(StringComparer.OrdinalIgnoreCase).Count())
        {
            return BadRequest(new { message = "SKU values must be unique." });
        }

        if (requestSkus.Count > 0)
        {
            var duplicateSkuExists = await _context.ProductVariants.AnyAsync(v =>
                v.ProductId != productId &&
                v.Sku != null &&
                requestSkus.Contains(v.Sku));
            if (duplicateSkuExists)
            {
                return BadRequest(new { message = "SKU already exists on another product." });
            }
        }

        var normalizedGroups = NormalizeGroups(dto.ClassificationGroups);
        var existingById = product.ProductVariants.ToDictionary(v => v.VariantId);
        var existingByCombination = product.ProductVariants
            .Select(v => new { Variant = v, Values = GetOptionValues(v, normalizedGroups) })
            .GroupBy(item => CombinationKey(item.Values))
            .ToDictionary(group => group.Key, group => group.First().Variant);
        var retainedIds = new HashSet<int>();

        await using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            product.ClassificationGroupsJson = JsonSerializer.Serialize(normalizedGroups);

            foreach (var input in dto.Variants)
            {
                var values = input.OptionValues.Select(value => value.Trim()).ToList();
                ProductVariant? variant = null;
                if (input.VariantId.HasValue)
                {
                    existingById.TryGetValue(input.VariantId.Value, out variant);
                    if (variant == null)
                    {
                        return BadRequest(new { message = "A variant does not belong to this product." });
                    }
                }
                else
                {
                    existingByCombination.TryGetValue(CombinationKey(values), out variant);
                }

                if (variant == null)
                {
                    variant = new ProductVariant { ProductId = productId };
                    product.ProductVariants.Add(variant);
                }

                ApplyClassificationValues(variant, normalizedGroups, values);
                variant.OptionValuesJson = JsonSerializer.Serialize(values);
                variant.Price = input.Price;
                variant.StockQuantity = input.StockQuantity;
                variant.Sku = NormalizeSku(input.Sku);
                variant.IsActive = input.IsActive;
                variant.ImageUrl = ResolveVariantImage(normalizedGroups, values, input.ImageUrl);

                if (variant.VariantId > 0)
                {
                    retainedIds.Add(variant.VariantId);
                }
            }

            foreach (var removed in product.ProductVariants
                         .Where(v => v.VariantId > 0 && !retainedIds.Contains(v.VariantId)))
            {
                removed.IsActive = false;
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
        }
        catch (DbUpdateException exception) when (IsUniqueConstraintViolation(exception))
        {
            await transaction.RollbackAsync();
            return BadRequest(new { message = "SKU already exists on another variant." });
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }

        return Ok(new { message = "Product classifications and variants saved successfully." });
    }

    private static string? ValidateClassificationRequest(SyncProductClassificationsDto dto)
    {
        if (dto.ClassificationGroups.Count is < 1 or > 2)
            return "Product must have one or two classification groups.";

        var groupNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var group in dto.ClassificationGroups)
        {
            if (string.IsNullOrWhiteSpace(group.Name))
                return "Classification name is required.";
            if (!groupNames.Add(group.Name.Trim()))
                return "Classification names must be unique.";
            if (group.Options.Count == 0)
                return $"Classification '{group.Name.Trim()}' must have at least one option.";

            var optionNames = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var option in group.Options)
            {
                if (string.IsNullOrWhiteSpace(option.Name))
                    return "Option name is required.";
                if (!optionNames.Add(option.Name.Trim()))
                    return $"Option '{option.Name.Trim()}' is duplicated in '{group.Name.Trim()}'.";
            }
        }

        var expectedCount = dto.ClassificationGroups.Aggregate(
            1,
            (count, group) => count * group.Options.Count);
        if (dto.Variants.Count != expectedCount)
            return "Variant list must contain every classification combination.";

        var combinations = new HashSet<string>();
        foreach (var variant in dto.Variants)
        {
            if (variant.OptionValues.Count != dto.ClassificationGroups.Count)
                return "Each variant must contain one option value per classification group.";

            for (var index = 0; index < variant.OptionValues.Count; index++)
            {
                var value = variant.OptionValues[index].Trim();
                if (!dto.ClassificationGroups[index].Options.Any(option =>
                        option.Name.Trim().Equals(value, StringComparison.OrdinalIgnoreCase)))
                    return $"Variant option '{value}' is invalid.";
            }

            if (!combinations.Add(CombinationKey(variant.OptionValues)))
                return "Variant combinations must be unique.";
        }

        return null;
    }

    private static bool IsUniqueConstraintViolation(DbUpdateException exception)
    {
        return exception.InnerException is SqlException { Number: 2601 or 2627 };
    }

    private static List<ProductClassificationGroupDto> NormalizeGroups(
        IEnumerable<ProductClassificationGroupDto> groups)
    {
        return groups.Select((group, groupIndex) => new ProductClassificationGroupDto
        {
            Name = group.Name.Trim(),
            SortOrder = groupIndex,
            Options = group.Options.Select((option, optionIndex) =>
                new ProductClassificationOptionDto
                {
                    Name = option.Name.Trim(),
                    Description = string.IsNullOrWhiteSpace(option.Description)
                        ? null
                        : option.Description.Trim(),
                    ImageUrl = NormalizeImageUrl(option.ImageUrl),
                    SortOrder = optionIndex
                }).ToList()
        }).ToList();
    }

    private static List<ProductClassificationGroupDto> DeserializeGroups(string? json)
    {
        if (string.IsNullOrWhiteSpace(json)) return new();
        try
        {
            return JsonSerializer.Deserialize<List<ProductClassificationGroupDto>>(json) ?? new();
        }
        catch (JsonException)
        {
            return new();
        }
    }

    private static List<ProductClassificationGroupDto> BuildLegacyGroups(
        IEnumerable<ProductVariant> variants)
    {
        var variantList = variants.ToList();
        var colors = variantList.Select(v => v.Color).Where(value => !string.IsNullOrWhiteSpace(value))
            .Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var sizes = variantList.Select(v => v.Size).Where(value => !string.IsNullOrWhiteSpace(value))
            .Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        var groups = new List<ProductClassificationGroupDto>();

        if (colors.Count > 0)
        {
            groups.Add(new ProductClassificationGroupDto
            {
                Name = "Color",
                SortOrder = 0,
                Options = colors.Select((color, index) => new ProductClassificationOptionDto
                {
                    Name = color,
                    ImageUrl = variantList.FirstOrDefault(v =>
                        v.Color.Equals(color, StringComparison.OrdinalIgnoreCase) &&
                        !string.IsNullOrWhiteSpace(v.ImageUrl))?.ImageUrl,
                    SortOrder = index
                }).ToList()
            });
        }

        if (sizes.Count > 0)
        {
            groups.Add(new ProductClassificationGroupDto
            {
                Name = "Size",
                SortOrder = groups.Count,
                Options = sizes.Select((size, index) => new ProductClassificationOptionDto
                {
                    Name = size,
                    SortOrder = index
                }).ToList()
            });
        }

        return groups.Take(2).ToList();
    }

    private static List<string> GetOptionValues(
        ProductVariant variant,
        IReadOnlyList<ProductClassificationGroupDto> groups)
    {
        if (!string.IsNullOrWhiteSpace(variant.OptionValuesJson))
        {
            try
            {
                var values = JsonSerializer.Deserialize<List<string>>(variant.OptionValuesJson);
                if (values?.Count == groups.Count) return values;
            }
            catch (JsonException)
            {
                // Fall back to legacy Size/Color fields.
            }
        }

        return groups.Select((group, index) =>
        {
            if (IsColorGroup(group.Name)) return variant.Color;
            if (IsSizeGroup(group.Name)) return variant.Size;
            return index == 0 && groups.Count == 2 ? variant.Color : variant.Size;
        }).ToList();
    }

    private static void ApplyClassificationValues(
        ProductVariant variant,
        IReadOnlyList<ProductClassificationGroupDto> groups,
        IReadOnlyList<string> values)
    {
        var colorIndex = FindGroupIndex(groups, IsColorGroup);
        var sizeIndex = FindGroupIndex(groups, IsSizeGroup);
        if (groups.Count == 2)
        {
            colorIndex ??= 0;
            sizeIndex ??= colorIndex == 0 ? 1 : 0;
        }
        else
        {
            sizeIndex ??= colorIndex == null ? 0 : null;
        }

        variant.Color = colorIndex.HasValue ? values[colorIndex.Value] : string.Empty;
        variant.Size = sizeIndex.HasValue ? values[sizeIndex.Value] : string.Empty;
    }

    private static string? ResolveVariantImage(
        IReadOnlyList<ProductClassificationGroupDto> groups,
        IReadOnlyList<string> values,
        string? requestedImageUrl)
    {
        if (!string.IsNullOrWhiteSpace(requestedImageUrl)) return requestedImageUrl.Trim();
        var colorIndex = FindGroupIndex(groups, IsColorGroup);
        if (!colorIndex.HasValue) return null;
        return groups[colorIndex.Value].Options.FirstOrDefault(option =>
            option.Name.Equals(values[colorIndex.Value], StringComparison.OrdinalIgnoreCase))?.ImageUrl;
    }

    private static int? FindGroupIndex(
        IReadOnlyList<ProductClassificationGroupDto> groups,
        Func<string, bool> predicate)
    {
        for (var index = 0; index < groups.Count; index++)
        {
            if (predicate(groups[index].Name)) return index;
        }
        return null;
    }

    private static bool IsColorGroup(string name)
    {
        var normalized = RemoveDiacritics(name).ToLowerInvariant();
        return normalized.Contains("color") || normalized.Contains("mau");
    }

    private static bool IsSizeGroup(string name)
    {
        var normalized = RemoveDiacritics(name).ToLowerInvariant();
        return normalized.Contains("size") || normalized.Contains("kich thuoc");
    }

    private static string RemoveDiacritics(string value)
    {
        var normalized = value.Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder();
        foreach (var character in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark)
                builder.Append(character);
        }
        return builder.ToString().Normalize(NormalizationForm.FormC).Replace('đ', 'd').Replace('Đ', 'D');
    }

    private static string CombinationKey(IEnumerable<string> values)
    {
        return string.Join("\u001f", values.Select(value => value.Trim().ToLowerInvariant()));
    }
}
