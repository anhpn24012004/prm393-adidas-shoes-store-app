using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ProductsController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public ProductsController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProducts()
    {
        var products = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Where(p => p.IsActive == true)
            .Select(p => new ProductDto
            {
                ProductId = p.ProductId,
                ProductName = p.ProductName,
                Description = p.Description,
                BasePrice = p.BasePrice,
                CategoryId = p.CategoryId,
                CategoryName = p.Category.CategoryName,
                Brand = p.Brand,
                Gender = p.Gender,
                Material = p.Material,
                MainImageUrl = p.ProductImages
                    .Where(i => i.IsMain == true)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                AverageRating = p.Reviews.Any()
                    ? p.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = p.Reviews.Count,
                IsActive = p.IsActive ?? false
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductDetailDto>> GetProductById(int id)
    {
        var product = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Include(p => p.ProductVariants)
            .Where(p => p.ProductId == id && p.IsActive == true)
            .Select(p => new ProductDetailDto
            {
                ProductId = p.ProductId,
                ProductName = p.ProductName,
                Description = p.Description,
                BasePrice = p.BasePrice,
                CategoryId = p.CategoryId,
                CategoryName = p.Category.CategoryName,
                Brand = p.Brand,
                Gender = p.Gender,
                Material = p.Material,
                AverageRating = p.Reviews.Any()
                    ? p.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = p.Reviews.Count,
                IsActive = p.IsActive ?? false,

                Images = p.ProductImages.Select(i => new ProductImageDto
                {
                    ImageId = i.ImageId,
                    ImageUrl = i.ImageUrl,
                    IsMain = i.IsMain ?? false
                }).ToList(),

                Variants = p.ProductVariants.Select(v => new ProductVariantDto
                {
                    VariantId = v.VariantId,
                    Size = v.Size,
                    Color = v.Color,
                    Price = v.Price,
                    StockQuantity = v.StockQuantity ?? 0,
                    Sku = v.Sku,
                    IsActive = v.IsActive ?? false
                }).ToList()
            })
            .FirstOrDefaultAsync();

        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        return Ok(product);
    }

    [HttpGet("search")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> SearchProducts([FromQuery] string keyword)
    {
        if (string.IsNullOrWhiteSpace(keyword))
        {
            return BadRequest(new { message = "Keyword is required" });
        }

        var products = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Where(p => p.IsActive == true && p.ProductName.Contains(keyword))
            .Select(p => new ProductDto
            {
                ProductId = p.ProductId,
                ProductName = p.ProductName,
                Description = p.Description,
                BasePrice = p.BasePrice,
                CategoryId = p.CategoryId,
                CategoryName = p.Category.CategoryName,
                Brand = p.Brand,
                Gender = p.Gender,
                Material = p.Material,
                MainImageUrl = p.ProductImages
                    .Where(i => i.IsMain == true)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                AverageRating = p.Reviews.Any()
                    ? p.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = p.Reviews.Count,
                IsActive = p.IsActive ?? false
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpGet("category/{categoryId}")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(int categoryId)
    {
        var products = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Where(p => p.IsActive == true && p.CategoryId == categoryId)
            .Select(p => new ProductDto
            {
                ProductId = p.ProductId,
                ProductName = p.ProductName,
                Description = p.Description,
                BasePrice = p.BasePrice,
                CategoryId = p.CategoryId,
                CategoryName = p.Category.CategoryName,
                Brand = p.Brand,
                Gender = p.Gender,
                Material = p.Material,
                MainImageUrl = p.ProductImages
                    .Where(i => i.IsMain == true)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                AverageRating = p.Reviews.Any()
                    ? p.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = p.Reviews.Count,
                IsActive = p.IsActive ?? false
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpPost]
    public async Task<IActionResult> CreateProduct(CreateProductDto dto)
    {
        var categoryExists = await _context.Categories
            .AnyAsync(c => c.CategoryId == dto.CategoryId);

        if (!categoryExists)
        {
            return BadRequest(new { message = "Category does not exist" });
        }

        var product = new Product
        {
            ProductName = dto.ProductName,
            Description = dto.Description,
            BasePrice = dto.BasePrice,
            CategoryId = dto.CategoryId,
            Brand = dto.Brand ?? "Adidas",
            Gender = dto.Gender,
            Material = dto.Material,
            IsActive = true,
            CreatedAt = DateTime.Now
        };

        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetProductById),
            new { id = product.ProductId },
            new
            {
                message = "Product created successfully",
                productId = product.ProductId
            }
        );
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, UpdateProductDto dto)
    {
        var product = await _context.Products.FindAsync(id);

        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        var categoryExists = await _context.Categories
            .AnyAsync(c => c.CategoryId == dto.CategoryId);

        if (!categoryExists)
        {
            return BadRequest(new { message = "Category does not exist" });
        }

        product.ProductName = dto.ProductName;
        product.Description = dto.Description;
        product.BasePrice = dto.BasePrice;
        product.CategoryId = dto.CategoryId;
        product.Brand = dto.Brand ?? "Adidas";
        product.Gender = dto.Gender;
        product.Material = dto.Material;
        product.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Product updated successfully" });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);

        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        product.IsActive = false;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Product deleted successfully" });
    }
}
