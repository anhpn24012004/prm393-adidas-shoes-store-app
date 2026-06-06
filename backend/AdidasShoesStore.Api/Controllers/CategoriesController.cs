using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Categories;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Route("api/[controller]")]
[ApiController]
public class CategoriesController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public CategoriesController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<CategoryDto>>> GetCategories()
    {
        var categories = await _context.Categories
            .AsNoTracking()
            .Select(c => new CategoryDto
            {
                CategoryId = c.CategoryId,
                CategoryName = c.CategoryName,
                Description = c.Description,
                ProductCount = c.Products.Count(p => p.IsActive == true)
            })
            .ToListAsync();

        return Ok(categories);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CategoryDto>> GetCategoryById(int id)
    {
        var category = await _context.Categories
            .AsNoTracking()
            .Where(c => c.CategoryId == id)
            .Select(c => new CategoryDto
            {
                CategoryId = c.CategoryId,
                CategoryName = c.CategoryName,
                Description = c.Description,
                ProductCount = c.Products.Count(p => p.IsActive == true)
            })
            .FirstOrDefaultAsync();

        if (category == null)
        {
            return NotFound(new { message = "Category not found" });
        }

        return Ok(category);
    }

    [HttpPost]
    public async Task<IActionResult> CreateCategory(CreateCategoryDto dto)
    {
        var categoryNameExists = await _context.Categories
            .AnyAsync(c => c.CategoryName == dto.CategoryName);

        if (categoryNameExists)
        {
            return BadRequest(new { message = "Category name already exists" });
        }

        var category = new Category
        {
            CategoryName = dto.CategoryName,
            Description = dto.Description
        };

        _context.Categories.Add(category);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetCategoryById),
            new { id = category.CategoryId },
            new
            {
                message = "Category created successfully",
                categoryId = category.CategoryId
            }
        );
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateCategory(int id, UpdateCategoryDto dto)
    {
        var category = await _context.Categories.FindAsync(id);

        if (category == null)
        {
            return NotFound(new { message = "Category not found" });
        }

        var categoryNameExists = await _context.Categories
            .AnyAsync(c => c.CategoryName == dto.CategoryName && c.CategoryId != id);

        if (categoryNameExists)
        {
            return BadRequest(new { message = "Category name already exists" });
        }

        category.CategoryName = dto.CategoryName;
        category.Description = dto.Description;

        await _context.SaveChangesAsync();

        return Ok(new { message = "Category updated successfully" });
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteCategory(int id)
    {
        var category = await _context.Categories
            .Include(c => c.Products)
            .FirstOrDefaultAsync(c => c.CategoryId == id);

        if (category == null)
        {
            return NotFound(new { message = "Category not found" });
        }

        var hasProducts = category.Products.Any();

        if (hasProducts)
        {
            return BadRequest(new
            {
                message = "Cannot delete category because it has products"
            });
        }

        _context.Categories.Remove(category);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Category deleted successfully" });
    }
}