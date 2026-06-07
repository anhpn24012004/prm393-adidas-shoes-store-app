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
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
            return NotFound();

        var result = new CartDto
        {
            CartId = cart.CartId,
            UserId = cart.UserId,
            CartItems = cart.CartItems.Select(x => new CartItemDto
            {
                CartItemId = x.CartItemId,
                VariantId = x.VariantId,
                Quantity = x.Quantity
            }).ToList()
        };

        return Ok(result);
    }

    // POST api/cart
    [HttpPost]
    public async Task<IActionResult> AddToCart(AddToCartDto dto)
    {
        var cart = await _context.Carts
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == dto.UserId);

        if (cart == null)
        {
            cart = new Cart
            {
                UserId = dto.UserId,
                CreatedAt = DateTime.Now
            };

            _context.Carts.Add(cart);
            await _context.SaveChangesAsync();
        }

        var existingItem = cart.CartItems
            .FirstOrDefault(x => x.VariantId == dto.VariantId);

        if (existingItem != null)
        {
            existingItem.Quantity += dto.Quantity;
        }
        else
        {
            _context.CartItems.Add(new CartItem
            {
                CartId = cart.CartId,
                VariantId = dto.VariantId,
                Quantity = dto.Quantity
            });
        }

        await _context.SaveChangesAsync();

        return Ok(new
        {
            Message = "Added to cart successfully"
        });
    }

    // PUT api/cart/item/5
    [HttpPut("item/{cartItemId}")]
    public async Task<IActionResult> UpdateQuantity(
        int cartItemId,
        UpdateCartItemDto dto)
    {
        var item = await _context.CartItems
            .FirstOrDefaultAsync(x => x.CartItemId == cartItemId);

        if (item == null)
            return NotFound();

        item.Quantity = dto.Quantity;

        await _context.SaveChangesAsync();

        return Ok(item);
    }

    // DELETE api/cart/item/5
    [HttpDelete("item/{cartItemId}")]
    public async Task<IActionResult> RemoveItem(int cartItemId)
    {
        var item = await _context.CartItems
            .FirstOrDefaultAsync(x => x.CartItemId == cartItemId);

        if (item == null)
            return NotFound();

        _context.CartItems.Remove(item);

        await _context.SaveChangesAsync();

        return NoContent();
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

        return NoContent();
    }
}