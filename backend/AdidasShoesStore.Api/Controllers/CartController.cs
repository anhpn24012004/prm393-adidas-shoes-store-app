using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Cart;
using AdidasShoesStore.Api.DTOs.Carts;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class CartController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public CartController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    // GET api/cart/user/1
    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetCartByUser(int userId)
    {
        var cart = await _context.Carts
            .AsNoTracking()
            .Include(c => c.CartItems)
                .ThenInclude(ci => ci.Variant)
                    .ThenInclude(v => v.Product)
                        .ThenInclude(p => p.ProductImages)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
        {
            return Ok(new
            {
                cartId = 0,
                userId,
                totalItems = 0,
                cartItems = Array.Empty<CartItemDetailDto>()
            });
        }

        var cartItems = cart.CartItems.Select(x => new CartItemDetailDto
        {
            CartItemId = x.CartItemId,
            VariantId = x.VariantId,
            ProductId = x.Variant.ProductId,
            ProductName = x.Variant.Product.ProductName,
            Size = x.Variant.Size,
            Color = x.Variant.Color,
            Price = x.Variant.Price,
            ImageUrl = x.Variant.Product.ProductImages
                .Where(i => i.IsMain == true)
                .Select(i => i.ImageUrl)
                .FirstOrDefault() ?? x.Variant.Product.ProductImages
                .OrderBy(i => i.ImageId)
                .Select(i => i.ImageUrl)
                .FirstOrDefault(),
            Quantity = x.Quantity
        }).ToList();

        var totalItems = cartItems.Sum(x => x.Quantity);

        return Ok(new
        {
            cartId = cart.CartId,
            userId = cart.UserId,
            totalItems,
            cartItems
        });
    }

    // GET api/cart/user/1/count
    [HttpGet("user/{userId}/count")]
    public async Task<IActionResult> GetCartCount(int userId)
    {
        var cart = await _context.Carts
            .AsNoTracking()
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        var totalItems = cart?.CartItems.Sum(x => x.Quantity) ?? 0;

        return Ok(new { totalItems });
    }

    // POST api/cart
    [HttpPost]
    public async Task<IActionResult> AddToCart(AddToCartDto request)
    {
        if (request.Quantity <= 0)
        {
            return BadRequest(new { message = "Quantity must be greater than 0" });
        }

        var variant = await _context.ProductVariants
            .Include(v => v.Product)
            .FirstOrDefaultAsync(v => v.VariantId == request.VariantId);

        if (variant == null)
        {
            return NotFound(new { message = "Product variant not found" });
        }

        if (variant.IsActive != true || variant.Product.IsActive != true)
        {
            return BadRequest(new { message = "Product variant is not available" });
        }

        var stockQuantity = variant.StockQuantity ?? 0;

        var cart = await _context.Carts
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == request.UserId);

        if (cart == null)
        {
            cart = new Cart
            {
                UserId = request.UserId,
                CreatedAt = DateTime.Now
            };

            _context.Carts.Add(cart);
            await _context.SaveChangesAsync();
        }

        var existingItem = await _context.CartItems
            .FirstOrDefaultAsync(x =>
                x.CartId == cart.CartId &&
                x.VariantId == request.VariantId);

        var currentCartQuantity = existingItem?.Quantity ?? 0;
        if (currentCartQuantity + request.Quantity > stockQuantity)
        {
            return BadRequest(new { message = $"Not enough stock. Available quantity: {stockQuantity}" });
        }

        if (existingItem != null)
        {
            existingItem.Quantity += request.Quantity;
        }
        else
        {
            _context.CartItems.Add(new CartItem
            {
                CartId = cart.CartId,
                VariantId = request.VariantId,
                Quantity = request.Quantity
            });
        }

        await _context.SaveChangesAsync();

        var totalItems = await _context.CartItems
            .Where(x => x.CartId == cart.CartId)
            .SumAsync(x => x.Quantity);

        return Ok(new
        {
            message = "Added to cart",
            totalItems
        });
    }

    // PUT api/cart/item/5
    [HttpPut("item/{cartItemId}")]
    public async Task<IActionResult> UpdateQuantity(
        int cartItemId,
        UpdateCartItemDto dto)
    {
        var item = await _context.CartItems
            .Include(x => x.Variant)
                .ThenInclude(v => v.Product)
            .FirstOrDefaultAsync(x => x.CartItemId == cartItemId);

        if (item == null)
            return NotFound();

        if (dto.Quantity <= 0)
        {
            _context.CartItems.Remove(item);
        }
        else
        {
            if (item.Variant.IsActive != true || item.Variant.Product.IsActive != true)
            {
                return BadRequest(new { message = "Product variant is not available" });
            }

            var stockQuantity = item.Variant.StockQuantity ?? 0;
            if (dto.Quantity > stockQuantity)
            {
                return BadRequest(new { message = $"Not enough stock. Available quantity: {stockQuantity}" });
            }

            item.Quantity = dto.Quantity;
        }

        await _context.SaveChangesAsync();

        var totalItems = await _context.CartItems
            .Where(x => x.CartId == item.CartId)
            .SumAsync(x => x.Quantity);

        return Ok(new { totalItems });
    }

    // DELETE api/cart/item/5
    [HttpDelete("item/{cartItemId}")]
    public async Task<IActionResult> RemoveItem(int cartItemId)
    {
        var item = await _context.CartItems
            .FirstOrDefaultAsync(x => x.CartItemId == cartItemId);

        if (item == null)
            return NotFound();

        var cartId = item.CartId;

        _context.CartItems.Remove(item);
        await _context.SaveChangesAsync();

        var totalItems = await _context.CartItems
            .Where(x => x.CartId == cartId)
            .SumAsync(x => x.Quantity);

        return Ok(new { totalItems });
    }

    // DELETE api/cart/user/1
    [HttpDelete("user/{userId}")]
    public async Task<IActionResult> ClearCart(int userId)
    {
        var cart = await _context.Carts
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(x => x.UserId == userId);

        if (cart == null)
            return NotFound();

        _context.CartItems.RemoveRange(cart.CartItems);
        await _context.SaveChangesAsync();

        return Ok(new { totalItems = 0 });
    }
}
