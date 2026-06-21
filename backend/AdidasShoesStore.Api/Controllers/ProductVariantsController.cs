using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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
                v.Size == dto.Size &&
                v.Color == dto.Color);

        if (duplicateVariantExists)
        {
            return BadRequest(new { message = "Variant with this size and color already exists." });
        }

        if (!string.IsNullOrWhiteSpace(dto.Sku))
        {
            var skuExists = await _context.ProductVariants
                .AnyAsync(v => v.Sku == dto.Sku);

            if (skuExists)
            {
                return BadRequest(new { message = "SKU already exists" });
            }
        }

        var variant = new ProductVariant
        {
            ProductId = productId,
            Size = dto.Size,
            Color = dto.Color,
            Price = dto.Price,
            StockQuantity = dto.StockQuantity,
            Sku = dto.Sku,
            IsActive = dto.IsActive
        };

        _context.ProductVariants.Add(variant);
        await _context.SaveChangesAsync();

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
                v.Size == dto.Size &&
                v.Color == dto.Color);

        if (duplicateVariantExists)
        {
            return BadRequest(new { message = "Variant with this size and color already exists." });
        }

        if (!string.IsNullOrWhiteSpace(dto.Sku))
        {
            var skuExists = await _context.ProductVariants
                .AnyAsync(v => v.Sku == dto.Sku && v.VariantId != variantId);

            if (skuExists)
            {
                return BadRequest(new { message = "SKU already exists" });
            }
        }

        variant.Size = dto.Size;
        variant.Color = dto.Color;
        variant.Price = dto.Price;
        variant.StockQuantity = dto.StockQuantity;
        variant.Sku = dto.Sku;
        variant.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();

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
}
