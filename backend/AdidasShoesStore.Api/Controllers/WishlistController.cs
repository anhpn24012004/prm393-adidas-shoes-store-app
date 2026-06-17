using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Wishlists;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class WishlistController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public WishlistController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    // GET api/wishlist/user/1
    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetWishlistByUser(int userId)
    {
        var items = await _context.Wishlists
            .AsNoTracking()
            .Where(w => w.UserId == userId)
            .Include(w => w.Product)
                .ThenInclude(p => p.ProductImages)
            .OrderByDescending(w => w.CreatedAt)
            .Select(w => new WishlistItemDto
            {
                WishlistId = w.WishlistId,
                ProductId = w.ProductId,
                ProductName = w.Product.ProductName,
                BasePrice = w.Product.BasePrice,
                ImageUrl = w.Product.ProductImages
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

    // GET api/wishlist/user/1/count
    [HttpGet("user/{userId}/count")]
    public async Task<IActionResult> GetWishlistCount(int userId)
    {
        var count = await _context.Wishlists
            .CountAsync(w => w.UserId == userId);

        return Ok(new { totalItems = count });
    }

    // POST api/wishlist
    [HttpPost]
    public async Task<IActionResult> AddToWishlist(AddToWishlistDto request)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == request.ProductId && p.IsActive == true);

        if (!productExists)
            return NotFound(new { message = "Product not found" });

        var existing = await _context.Wishlists
            .FirstOrDefaultAsync(w =>
                w.UserId == request.UserId &&
                w.ProductId == request.ProductId);

        if (existing != null)
        {
            var existingCount = await _context.Wishlists
                .CountAsync(w => w.UserId == request.UserId);

            return Ok(new
            {
                message = "Product already in wishlist",
                totalItems = existingCount
            });
        }

        _context.Wishlists.Add(new Wishlist
        {
            UserId = request.UserId,
            ProductId = request.ProductId,
            CreatedAt = DateTime.Now
        });

        await _context.SaveChangesAsync();

        var totalItems = await _context.Wishlists
            .CountAsync(w => w.UserId == request.UserId);

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
        var item = await _context.Wishlists
            .FirstOrDefaultAsync(w => w.WishlistId == wishlistId);

        if (item == null)
            return NotFound();

        var userId = item.UserId;

        _context.Wishlists.Remove(item);
        await _context.SaveChangesAsync();

        var totalItems = await _context.Wishlists
            .CountAsync(w => w.UserId == userId);

        return Ok(new { totalItems });
    }

    // DELETE api/wishlist/user/1
    [HttpDelete("user/{userId}")]
    public async Task<IActionResult> ClearWishlist(int userId)
    {
        var items = await _context.Wishlists
            .Where(w => w.UserId == userId)
            .ToListAsync();

        if (items.Count == 0)
            return NotFound();

        _context.Wishlists.RemoveRange(items);
        await _context.SaveChangesAsync();

        return Ok(new { totalItems = 0 });
    }
}
