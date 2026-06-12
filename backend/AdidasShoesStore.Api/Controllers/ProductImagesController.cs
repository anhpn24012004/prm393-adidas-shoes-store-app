using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api")]
[ApiController]
public class ProductImagesController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public ProductImagesController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet("products/{productId}/images")]
    public async Task<ActionResult<IEnumerable<ProductImageDto>>> GetImagesByProduct(int productId)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId && p.IsActive == true);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        var images = await _context.ProductImages
            .AsNoTracking()
            .Where(i => i.ProductId == productId)
            .Select(i => new ProductImageDto
            {
                ImageId = i.ImageId,
                ImageUrl = i.ImageUrl,
                IsMain = i.IsMain ?? false
            })
            .ToListAsync();

        return Ok(images);
    }

    [HttpPost("products/{productId}/images")]
    public async Task<IActionResult> CreateImage(int productId, CreateProductImageDto dto)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId && p.IsActive == true);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        if (dto.IsMain)
        {
            var oldMainImages = await _context.ProductImages
                .Where(i => i.ProductId == productId && i.IsMain == true)
                .ToListAsync();

            foreach (var image in oldMainImages)
            {
                image.IsMain = false;
            }
        }

        var productImage = new ProductImage
        {
            ProductId = productId,
            ImageUrl = dto.ImageUrl,
            IsMain = dto.IsMain
        };

        _context.ProductImages.Add(productImage);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Product image created successfully",
            imageId = productImage.ImageId
        });
    }

    [HttpPut("productimages/{imageId}")]
    public async Task<IActionResult> UpdateImage(int imageId, UpdateProductImageDto dto)
    {
        var image = await _context.ProductImages.FindAsync(imageId);

        if (image == null)
        {
            return NotFound(new { message = "Product image not found" });
        }

        if (dto.IsMain)
        {
            var oldMainImages = await _context.ProductImages
                .Where(i => i.ProductId == image.ProductId && i.ImageId != imageId && i.IsMain == true)
                .ToListAsync();

            foreach (var oldImage in oldMainImages)
            {
                oldImage.IsMain = false;
            }
        }

        image.ImageUrl = dto.ImageUrl;
        image.IsMain = dto.IsMain;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Product image updated successfully" });
    }

    [HttpDelete("productimages/{imageId}")]
    public async Task<IActionResult> DeleteImage(int imageId)
    {
        var image = await _context.ProductImages.FindAsync(imageId);

        if (image == null)
        {
            return NotFound(new { message = "Product image not found" });
        }

        _context.ProductImages.Remove(image);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Product image deleted successfully" });
    }
}