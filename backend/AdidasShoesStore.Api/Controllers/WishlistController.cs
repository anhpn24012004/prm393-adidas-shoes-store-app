using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Wishlists;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class WishlistController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public WishlistController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    // GET api/wishlist/my
    [HttpGet("my")]
    public async Task<IActionResult> GetMyWishlist()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var items = await _context.Wishlists
            .AsNoTracking()
            .AsSplitQuery()
            .Where(w => w.UserId == userId)
            .Include(w => w.Product)
                .ThenInclude(p => p.ProductImages)
            .Include(w => w.Variant)
            .OrderByDescending(w => w.CreatedAt)
            .Select(w => new WishlistItemDto
            {
                WishlistId = w.WishlistId,
                ProductId = w.ProductId,
                ProductName = w.Product.ProductName,
                BasePrice = w.Product.BasePrice,
                ImageUrl = w.Variant != null && w.Variant.ImageUrl != null
                    ? w.Variant.ImageUrl
                    : w.Product.ProductImages
                    .Where(i => i.IsMain == true)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                AverageRating = w.Product.Reviews.Any()
                    ? w.Product.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = w.Product.Reviews.Count,
                CreatedAt = w.CreatedAt
            })
            .ToListAsync();

        return Ok(items);
    }

    // GET api/wishlist/my/count
    [HttpGet("my/count")]
    public async Task<IActionResult> GetMyWishlistCount()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var count = await _context.Wishlists
            .CountAsync(w => w.UserId == userId);

        return Ok(new { totalItems = count });
    }

    // POST api/wishlist
    [HttpPost]
    public async Task<IActionResult> AddToWishlist(AddToWishlistDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == request.ProductId && p.IsActive == true);

        if (!productExists)
            return NotFound(new { message = "Product not found" });

        if (request.VariantId.HasValue)
        {
            var variantExists = await _context.ProductVariants.AnyAsync(v =>
                v.VariantId == request.VariantId.Value &&
                v.ProductId == request.ProductId &&
                v.IsActive == true);
            if (!variantExists)
                return BadRequest(new { message = "Selected product variant is invalid" });
        }

        var existing = await _context.Wishlists
            .FirstOrDefaultAsync(w =>
                w.UserId == userId &&
                w.ProductId == request.ProductId);

        if (existing != null)
        {
            if (request.VariantId.HasValue)
            {
                existing.VariantId = request.VariantId;
                await _context.SaveChangesAsync();
            }

            var existingCount = await _context.Wishlists
                .CountAsync(w => w.UserId == userId);

            return Ok(new
            {
                message = "Product already in wishlist",
                totalItems = existingCount
            });
        }

        _context.Wishlists.Add(new Wishlist
        {
            UserId = userId,
            ProductId = request.ProductId,
            VariantId = request.VariantId,
            CreatedAt = DateTime.UtcNow
        });

        await _context.SaveChangesAsync();

        var totalItems = await _context.Wishlists
            .CountAsync(w => w.UserId == userId);

        return Ok(new
        {
            message = "Added to wishlist",
            totalItems
        });
    }

    // DELETE api/wishlist/5
    [HttpDelete("{wishlistId}")]
    public async Task<IActionResult> RemoveItem(int wishlistId)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var item = await _context.Wishlists
            .FirstOrDefaultAsync(w => w.WishlistId == wishlistId && w.UserId == userId);

        if (item == null)
            return NotFound();

        _context.Wishlists.Remove(item);
        await _context.SaveChangesAsync();

        var totalItems = await _context.Wishlists
            .CountAsync(w => w.UserId == userId);

        return Ok(new { totalItems });
    }

    // DELETE api/wishlist/my
    [HttpDelete("my")]
    public async Task<IActionResult> ClearMyWishlist()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid access token" });
        }

        var items = await _context.Wishlists
            .Where(w => w.UserId == userId)
            .ToListAsync();

        if (items.Count == 0)
            return NotFound();

        _context.Wishlists.RemoveRange(items);
        await _context.SaveChangesAsync();

        return Ok(new { totalItems = 0 });
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(value, out userId);
    }
}
