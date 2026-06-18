using System.Security.Claims;
using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Authorize(Roles = "Admin")]
[ApiController]
[Route("api/admin/users")]
public class AdminUsersController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public AdminUsersController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetUsers(
        [FromQuery] string? keyword,
        [FromQuery] bool? isActive)
    {
        var query = _context.Users
            .AsNoTracking()
            .Include(user => user.Role)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var trimmedKeyword = keyword.Trim();
            query = query.Where(user =>
                user.FullName.Contains(trimmedKeyword) ||
                user.Email.Contains(trimmedKeyword) ||
                (user.Phone != null && user.Phone.Contains(trimmedKeyword)));
        }

        if (isActive.HasValue)
        {
            query = query.Where(user => user.IsActive == isActive.Value);
        }

        var users = await query
            .OrderByDescending(user => user.CreatedAt)
            .Select(user => new AdminUserDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                Gender = user.Gender,
                RoleName = user.Role.RoleName,
                IsActive = user.IsActive == true,
                CreatedAt = user.CreatedAt,
                OrderCount = user.Orders.Count,
                ReturnRequestCount = user.ReturnRequests.Count
            })
            .ToListAsync();

        return Ok(users);
    }

    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> UpdateUserStatus(
        int id,
        UpdateUserStatusDto dto)
    {
        var currentUserId = GetCurrentUserId();
        if (currentUserId == id && !dto.IsActive)
        {
            return BadRequest(new { message = "Admin cannot deactivate their own account" });
        }

        var user = await _context.Users.FirstOrDefaultAsync(item => item.UserId == id);

        if (user == null)
        {
            return NotFound(new { message = "User not found" });
        }

        user.IsActive = dto.IsActive;
        await _context.SaveChangesAsync();

        return Ok(new { message = "User status updated" });
    }

    private int? GetCurrentUserId()
    {
        var value = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(value, out var userId) ? userId : null;
    }
}
