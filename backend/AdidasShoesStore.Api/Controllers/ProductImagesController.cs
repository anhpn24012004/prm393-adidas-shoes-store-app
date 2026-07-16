using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api")]
[ApiController]
public class ProductImagesController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;
    private readonly IWebHostEnvironment _environment;
    private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    };
    private const long MaxImageBytes = 5 * 1024 * 1024;

    public ProductImagesController(
        AdidasShoesStoreContext context,
        IWebHostEnvironment environment)
    {
        _context = context;
        _environment = environment;
    }

    [HttpGet("products/{productId}/images")]
    public async Task<ActionResult<IEnumerable<ProductImageDto>>> GetImagesByProduct(int productId)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId);

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

        return Ok(ProductImageDeduplicator.GetUniqueImages(images));
    }

    [HttpPost("products/{productId}/images")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> CreateImage(int productId, CreateProductImageDto dto)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        var imageUrl = dto.ImageUrl.Trim();
        if (imageUrl.Length == 0)
        {
            return BadRequest(new { message = "Image URL is required." });
        }

        var existingImageUrls = await _context.ProductImages
            .AsNoTracking()
            .Where(i => i.ProductId == productId)
            .Select(i => i.ImageUrl)
            .ToListAsync();

        if (existingImageUrls.Any(existingUrl =>
            string.Equals(
                existingUrl?.Trim(),
                imageUrl,
                StringComparison.OrdinalIgnoreCase)))
        {
            return BadRequest(new
            {
                message = "This image already exists for this product."
            });
        }

        var hasImages = await _context.ProductImages
            .AnyAsync(i => i.ProductId == productId);

        if (dto.IsMain || !hasImages)
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
            ImageUrl = imageUrl,
            IsMain = dto.IsMain || !hasImages
        };

        _context.ProductImages.Add(productImage);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Product image created successfully",
            imageId = productImage.ImageId
        });
    }

    [HttpPost("products/{productId}/images/upload")]
    [Consumes("multipart/form-data")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ProductImageDto>> UploadImage(
        int productId,
        IFormFile file,
        [FromForm] bool isMain)
    {
        var productExists = await _context.Products
            .AnyAsync(p => p.ProductId == productId);

        if (!productExists)
        {
            return NotFound(new { message = "Product not found" });
        }

        if (file == null || file.Length == 0)
        {
            return BadRequest(new { message = "Image file is required" });
        }

        if (file.Length > MaxImageBytes)
        {
            return BadRequest(new { message = "Image file must be 5MB or smaller" });
        }

        var extension = Path.GetExtension(file.FileName);
        if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
        {
            return BadRequest(new { message = "Only .jpg, .jpeg, .png and .webp files are allowed" });
        }

        var hasImages = await _context.ProductImages
            .AnyAsync(i => i.ProductId == productId);
        var shouldBeMain = isMain || !hasImages;

        if (shouldBeMain)
        {
            var oldMainImages = await _context.ProductImages
                .Where(i => i.ProductId == productId && i.IsMain == true)
                .ToListAsync();

            foreach (var oldImage in oldMainImages)
            {
                oldImage.IsMain = false;
            }
        }

        var fileName = $"{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
        var relativeDirectory = Path.Combine("images", "products", productId.ToString());
        var webRoot = _environment.WebRootPath ??
            Path.Combine(_environment.ContentRootPath, "wwwroot");
        var absoluteDirectory = Path.Combine(webRoot, relativeDirectory);
        Directory.CreateDirectory(absoluteDirectory);

        var absolutePath = Path.Combine(absoluteDirectory, fileName);
        await using (var stream = System.IO.File.Create(absolutePath))
        {
            await file.CopyToAsync(stream);
        }

        var imageUrl = $"/images/products/{productId}/{fileName}";
        var productImage = new ProductImage
        {
            ProductId = productId,
            ImageUrl = imageUrl,
            IsMain = shouldBeMain
        };

        _context.ProductImages.Add(productImage);
        await _context.SaveChangesAsync();

        return Ok(new ProductImageDto
        {
            ImageId = productImage.ImageId,
            ImageUrl = productImage.ImageUrl,
            IsMain = productImage.IsMain ?? false
        });
    }

    [HttpPut("productimages/{imageId}")]
    [Authorize(Roles = "Admin")]
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
        await EnsureMainImageAsync(image.ProductId);

        return Ok(new { message = "Product image updated successfully" });
    }

    [HttpDelete("productimages/{imageId}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteImage(int imageId)
    {
        var image = await _context.ProductImages.FindAsync(imageId);

        if (image == null)
        {
            return NotFound(new { message = "Product image not found" });
        }

        var productId = image.ProductId;

        _context.ProductImages.Remove(image);
        await _context.SaveChangesAsync();
        await EnsureMainImageAsync(productId);

        return Ok(new { message = "Product image deleted successfully" });
    }

    private async Task EnsureMainImageAsync(int productId)
    {
        var images = await _context.ProductImages
            .Where(i => i.ProductId == productId)
            .OrderBy(i => i.ImageId)
            .ToListAsync();

        if (images.Count == 0)
        {
            var product = await _context.Products.FindAsync(productId);
            if (product != null)
            {
                product.IsActive = false;
                await _context.SaveChangesAsync();
            }

            return;
        }

        if (images.Any(i => i.IsMain == true))
        {
            return;
        }

        images[0].IsMain = true;
        await _context.SaveChangesAsync();
    }
}
