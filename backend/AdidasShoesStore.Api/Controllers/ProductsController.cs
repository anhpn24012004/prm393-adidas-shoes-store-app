using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs;
using AdidasShoesStore.Api.DTOs.Products;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
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
    public async Task<ActionResult<PagedResultDto<ProductDto>>> GetProducts(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 8,
        [FromQuery] string? keyword = null,
        [FromQuery] int? categoryId = null)
    {
        var result = await GetPagedProductsAsync(
            pageNumber,
            pageSize,
            keyword,
            categoryId,
            userVisibleOnly: true);
        return Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet("admin")]
    public async Task<ActionResult<PagedResultDto<ProductDto>>> GetAdminProducts(
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? keyword = null,
        [FromQuery] int? categoryId = null,
        [FromQuery] bool? isActive = null)
    {
        var result = await GetPagedProductsAsync(
            pageNumber,
            pageSize,
            keyword,
            categoryId,
            userVisibleOnly: false,
            isActive);

        return Ok(result);
    }

    private async Task<PagedResultDto<ProductDto>> GetPagedProductsAsync(
        int pageNumber,
        int pageSize,
        string? keyword = null,
        int? categoryId = null,
        bool userVisibleOnly = true,
        bool? isActive = null)
    {
        const int defaultPageSize = 8;
        const int maxPageSize = 50;

        if (pageNumber < 1)
        {
            pageNumber = 1;
        }

        if (pageSize < 1)
        {
            pageSize = defaultPageSize;
        }

        pageSize = Math.Min(pageSize, maxPageSize);

        var query = _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Include(p => p.Reviews)
            .Include(p => p.ProductVariants)
            .AsQueryable();

        if (userVisibleOnly)
        {
            query = query.Where(p =>
                p.IsActive == true &&
                p.ProductImages.Any() &&
                p.ProductVariants.Any(v =>
                    v.IsActive == true &&
                    (v.StockQuantity ?? 0) > 0));
        }
        else if (isActive.HasValue)
        {
            query = query.Where(p => (p.IsActive ?? false) == isActive.Value);
        }

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            query = query.Where(p => p.ProductName.Contains(keyword));
        }

        if (categoryId.HasValue)
        {
            query = query.Where(p => p.CategoryId == categoryId.Value);
        }

        var totalItems = await query.CountAsync();
        var totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);

        var products = await query
            .OrderByDescending(p => p.CreatedAt)
            .ThenBy(p => p.ProductId)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
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
                    .FirstOrDefault() ?? p.ProductImages
                    .OrderBy(i => i.ImageId)
                    .Select(i => i.ImageUrl)
                    .FirstOrDefault(),
                AverageRating = p.Reviews.Any()
                    ? p.Reviews.Average(r => r.Rating)
                    : 0,
                ReviewCount = p.Reviews.Count,
                IsActive = p.IsActive ?? false,
                ImageCount = p.ProductImages.Count,
                ActiveVariantCount = p.ProductVariants.Count(v => v.IsActive == true),
                TotalStock = p.ProductVariants
                    .Where(v => v.IsActive == true)
                    .Sum(v => v.StockQuantity ?? 0)
            })
            .ToListAsync();

        return new PagedResultDto<ProductDto>
        {
            Items = products,
            PageNumber = pageNumber,
            PageSize = pageSize,
            TotalItems = totalItems,
            TotalPages = totalPages,
            HasPreviousPage = pageNumber > 1,
            HasNextPage = pageNumber < totalPages
        };
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProductDetailDto>> GetProductById(int id)
    {
        var product = await _context.Products
            .AsNoTracking()
            .Include(p => p.Category)
            .Include(p => p.ProductImages)
            .Include(p => p.ProductVariants)
            .Where(p =>
                p.ProductId == id &&
                p.IsActive == true &&
                p.ProductImages.Any() &&
                p.ProductVariants.Any(v =>
                    v.IsActive == true &&
                    (v.StockQuantity ?? 0) > 0))
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

                Images = p.ProductImages
                    .OrderByDescending(i => i.IsMain == true)
                    .ThenBy(i => i.ImageId)
                    .Select(i => new ProductImageDto
                    {
                        ImageId = i.ImageId,
                        ImageUrl = i.ImageUrl,
                        IsMain = i.IsMain ?? false
                    }).ToList(),

                Variants = p.ProductVariants
                    .Where(v => v.IsActive == true)
                    .Select(v => new ProductVariantDto
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

        var products = (await GetPagedProductsAsync(
            1,
            50,
            keyword,
            userVisibleOnly: true)).Items;

        return Ok(products);
    }

    [HttpGet("category/{categoryId}")]
    public async Task<ActionResult<IEnumerable<ProductDto>>> GetProductsByCategory(int categoryId)
    {
        var products = (await GetPagedProductsAsync(
            1,
            50,
            categoryId: categoryId,
            userVisibleOnly: true)).Items;

        return Ok(products);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
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
            IsActive = false,
            CreatedAt = DateTime.Now
        };

        _context.Products.Add(product);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetProductById),
            new { id = product.ProductId },
            new
            {
                message = "Product created as draft",
                productId = product.ProductId
            }
        );
    }

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
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
        if (dto.IsActive)
        {
            var validationMessage = await GetPublishValidationMessageAsync(id);
            if (validationMessage != null)
            {
                return BadRequest(new { message = validationMessage });
            }
        }

        product.IsActive = dto.IsActive;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Product updated successfully" });
    }

    [HttpPost("{id:int}/publish")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> PublishProduct(int id)
    {
        var product = await _context.Products.FindAsync(id);

        if (product == null)
        {
            return NotFound(new { message = "Product not found" });
        }

        var validationMessage = await GetPublishValidationMessageAsync(id);
        if (validationMessage != null)
        {
            product.IsActive = false;
            await _context.SaveChangesAsync();
            return BadRequest(new { message = validationMessage });
        }

        product.IsActive = true;
        await _context.SaveChangesAsync();

        return Ok(new { message = "Product published successfully" });
    }

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
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

    private async Task<string?> GetPublishValidationMessageAsync(int productId)
    {
        var hasImage = await _context.ProductImages
            .AnyAsync(i => i.ProductId == productId);

        if (!hasImage)
        {
            return "Product must have at least one image before publishing.";
        }

        var hasActiveVariant = await _context.ProductVariants
            .AnyAsync(v => v.ProductId == productId && v.IsActive == true);

        if (!hasActiveVariant)
        {
            return "Product must have at least one active variant before publishing.";
        }

        var hasStock = await _context.ProductVariants
            .AnyAsync(v =>
                v.ProductId == productId &&
                v.IsActive == true &&
                (v.StockQuantity ?? 0) > 0);

        if (!hasStock)
        {
            return "Product must have stock before publishing.";
        }

        return null;
    }
}
