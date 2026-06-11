using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Returns;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class ReturnRequestService : IReturnRequestService
{
    private readonly AdidasShoesStoreContext _context;

    public ReturnRequestService(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    public async Task<List<ReturnRequestDto>> GetAllAsync()
    {
        return await _context.ReturnRequests
            .OrderByDescending(r => r.RequestedAt)
            .Select(r => new ReturnRequestDto
            {
                ReturnRequestId = r.ReturnRequestId,
                OrderId = r.OrderId,
                UserId = r.UserId,
                Reason = r.Reason,
                Status = r.Status,
                RequestedAt = r.RequestedAt,
                AdminNote = r.AdminNote
            })
            .ToListAsync();
    }

    public async Task<List<ReturnRequestDto>> GetByUserIdAsync(int userId)
    {
        return await _context.ReturnRequests
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.RequestedAt)
            .Select(r => new ReturnRequestDto
            {
                ReturnRequestId = r.ReturnRequestId,
                OrderId = r.OrderId,
                UserId = r.UserId,
                Reason = r.Reason,
                Status = r.Status,
                RequestedAt = r.RequestedAt,
                AdminNote = r.AdminNote
            })
            .ToListAsync();
    }

    public async Task<ReturnRequestDto?> CreateAsync(CreateReturnRequestDto dto)
    {
        if (dto.Items == null || dto.Items.Count == 0)
            return null;

        var order = await _context.Orders
            .Include(o => o.OrderItems)
            .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId && o.UserId == dto.UserId);

        if (order == null)
            return null;

        if (order.Status != "Delivered" && order.Status != "Completed")
            return null;

        var existingRequest = await _context.ReturnRequests
            .AnyAsync(r => r.OrderId == dto.OrderId && r.UserId == dto.UserId && r.Status != "Rejected");

        if (existingRequest)
            return null;

        foreach (var item in dto.Items)
        {
            var orderItem = order.OrderItems.FirstOrDefault(oi => oi.OrderItemId == item.OrderItemId);

            if (orderItem == null)
                return null;

            if (item.Quantity <= 0 || item.Quantity > orderItem.Quantity)
                return null;
        }

        var returnRequest = new ReturnRequest
        {
            OrderId = dto.OrderId,
            UserId = dto.UserId,
            Reason = dto.Reason,
            Status = "Pending",
            RequestedAt = DateTime.Now
        };

        _context.ReturnRequests.Add(returnRequest);
        await _context.SaveChangesAsync();

        foreach (var item in dto.Items)
        {
            var returnItem = new ReturnItem
            {
                ReturnRequestId = returnRequest.ReturnRequestId,
                OrderItemId = item.OrderItemId,
                Quantity = item.Quantity,
                Reason = item.Reason
            };

            _context.ReturnItems.Add(returnItem);
        }

        await _context.SaveChangesAsync();

        return new ReturnRequestDto
        {
            ReturnRequestId = returnRequest.ReturnRequestId,
            OrderId = returnRequest.OrderId,
            UserId = returnRequest.UserId,
            Reason = returnRequest.Reason,
            Status = returnRequest.Status,
            RequestedAt = returnRequest.RequestedAt,
            AdminNote = returnRequest.AdminNote
        };
    }

    public async Task<bool> ApproveAsync(int returnRequestId, string? adminNote)
    {
        var request = await _context.ReturnRequests
            .Include(r => r.ReturnItems)
            .ThenInclude(ri => ri.OrderItem)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);

        if (request == null || request.Status != "Pending")
            return false;

        request.Status = "Approved";
        request.AdminNote = adminNote;

        var refundAmount = request.ReturnItems
            .Sum(ri => ri.Quantity * ri.OrderItem.UnitPrice);

        var refund = new Refund
        {
            ReturnRequestId = request.ReturnRequestId,
            OrderId = request.OrderId,
            Amount = refundAmount,
            Status = "Pending",
            PaymentMethod = "Original Payment",
            RefundedAt = null
        };

        _context.Refunds.Add(refund);
        await _context.SaveChangesAsync();

        return true;
    }

    public async Task<bool> RejectAsync(int returnRequestId, string? adminNote)
    {
        var request = await _context.ReturnRequests
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);

        if (request == null || request.Status != "Pending")
            return false;

        request.Status = "Rejected";
        request.AdminNote = adminNote;

        await _context.SaveChangesAsync();

        return true;
    }
}
