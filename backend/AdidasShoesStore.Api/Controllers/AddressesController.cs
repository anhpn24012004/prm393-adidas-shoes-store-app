using System.Security.Claims;
using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.UserAddresses;
using AdidasShoesStore.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Controllers;

[Authorize]
[ApiController]
[Route("api/addresses")]
public class AddressesController : ControllerBase
{
    private readonly AdidasShoesStoreContext _context;

    public AddressesController(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetMyAddresses()
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var addresses = await _context.UserAddresses
            .AsNoTracking()
            .Where(address => address.UserId == userId)
            .OrderByDescending(address => address.IsDefault == true)
            .ThenBy(address => address.AddressId)
            .Select(address => new UserAddressDto
            {
                AddressId = address.AddressId,
                ReceiverName = address.ReceiverName,
                Phone = address.Phone,
                AddressLine = address.AddressLine,
                Ward = address.Ward,
                District = address.District,
                City = address.City,
                IsDefault = address.IsDefault == true
            })
            .ToListAsync();

        return Ok(addresses);
    }

    [HttpPost]
    public async Task<IActionResult> CreateAddress(SaveUserAddressDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var hasAddress = await _context.UserAddresses
            .AnyAsync(address => address.UserId == userId);
        var shouldBeDefault = request.IsDefault || !hasAddress;

        if (shouldBeDefault)
        {
            await ClearDefaultAddressAsync(userId);
        }

        var address = new UserAddress
        {
            UserId = userId,
            ReceiverName = request.ReceiverName.Trim(),
            Phone = request.Phone.Trim(),
            AddressLine = request.AddressLine.Trim(),
            Ward = Normalize(request.Ward),
            District = Normalize(request.District),
            City = Normalize(request.City),
            IsDefault = shouldBeDefault
        };

        _context.UserAddresses.Add(address);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(GetMyAddresses),
            new { id = address.AddressId },
            ToDto(address)
        );
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> UpdateAddress(
        int id,
        SaveUserAddressDto request)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var address = await _context.UserAddresses
            .FirstOrDefaultAsync(item =>
                item.AddressId == id &&
                item.UserId == userId);

        if (address == null)
        {
            return NotFound(new { message = "Address not found" });
        }

        if (request.IsDefault)
        {
            await ClearDefaultAddressAsync(userId, id);
        }

        address.ReceiverName = request.ReceiverName.Trim();
        address.Phone = request.Phone.Trim();
        address.AddressLine = request.AddressLine.Trim();
        address.Ward = Normalize(request.Ward);
        address.District = Normalize(request.District);
        address.City = Normalize(request.City);
        address.IsDefault = request.IsDefault || address.IsDefault == true;

        await _context.SaveChangesAsync();
        return Ok(ToDto(address));
    }

    [HttpPut("{id:int}/default")]
    public async Task<IActionResult> SetDefaultAddress(int id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var address = await _context.UserAddresses
            .FirstOrDefaultAsync(item =>
                item.AddressId == id &&
                item.UserId == userId);

        if (address == null)
        {
            return NotFound(new { message = "Address not found" });
        }

        await ClearDefaultAddressAsync(userId, id);
        address.IsDefault = true;
        await _context.SaveChangesAsync();

        return Ok(ToDto(address));
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> DeleteAddress(int id)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Invalid token" });
        }

        var address = await _context.UserAddresses
            .FirstOrDefaultAsync(item =>
                item.AddressId == id &&
                item.UserId == userId);

        if (address == null)
        {
            return NotFound(new { message = "Address not found" });
        }

        var wasDefault = address.IsDefault == true;
        _context.UserAddresses.Remove(address);
        await _context.SaveChangesAsync();

        if (wasDefault)
        {
            var replacement = await _context.UserAddresses
                .Where(item => item.UserId == userId)
                .OrderBy(item => item.AddressId)
                .FirstOrDefaultAsync();

            if (replacement != null)
            {
                replacement.IsDefault = true;
                await _context.SaveChangesAsync();
            }
        }

        return NoContent();
    }

    private async Task ClearDefaultAddressAsync(
        int userId,
        int? excludedAddressId = null)
    {
        var addresses = await _context.UserAddresses
            .Where(address =>
                address.UserId == userId &&
                address.IsDefault == true &&
                (!excludedAddressId.HasValue ||
                 address.AddressId != excludedAddressId.Value))
            .ToListAsync();

        foreach (var address in addresses)
        {
            address.IsDefault = false;
        }
    }

    private static UserAddressDto ToDto(UserAddress address)
    {
        return new UserAddressDto
        {
            AddressId = address.AddressId,
            ReceiverName = address.ReceiverName,
            Phone = address.Phone,
            AddressLine = address.AddressLine,
            Ward = address.Ward,
            District = address.District,
            City = address.City,
            IsDefault = address.IsDefault == true
        };
    }

    private static string? Normalize(string? value)
    {
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }

    private bool TryGetUserId(out int userId)
    {
        var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(value, out userId);
    }
}
