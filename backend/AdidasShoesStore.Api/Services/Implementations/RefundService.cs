using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Refunds;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class RefundService : IRefundService
{
    private readonly AdidasShoesStoreContext _context;

    public RefundService(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    public async Task<List<RefundDto>> GetAllAsync()
    {
        return await _context.Refunds
            .OrderByDescending(r => r.RefundId)
            .Select(r => new RefundDto
            {
                RefundId = r.RefundId,
                ReturnRequestId = r.ReturnRequestId,
                OrderId = r.OrderId,
                Amount = r.Amount,
                Status = r.Status,
                PaymentMethod = r.PaymentMethod,
                TransactionCode = r.TransactionCode,
                RefundedAt = r.RefundedAt
            })
            .ToListAsync();
    }

    public async Task<List<RefundDto>> GetByOrderIdAsync(int orderId)
    {
        return await _context.Refunds
            .Where(r => r.OrderId == orderId)
            .OrderByDescending(r => r.RefundId)
            .Select(r => new RefundDto
            {
                RefundId = r.RefundId,
                ReturnRequestId = r.ReturnRequestId,
                OrderId = r.OrderId,
                Amount = r.Amount,
                Status = r.Status,
                PaymentMethod = r.PaymentMethod,
                TransactionCode = r.TransactionCode,
                RefundedAt = r.RefundedAt
            })
            .ToListAsync();
    }

    public async Task<RefundDto?> GetByReturnRequestIdAsync(int returnRequestId)
    {
        return await _context.Refunds
            .Where(r => r.ReturnRequestId == returnRequestId)
            .Select(r => new RefundDto
            {
                RefundId = r.RefundId,
                ReturnRequestId = r.ReturnRequestId,
                OrderId = r.OrderId,
                Amount = r.Amount,
                Status = r.Status,
                PaymentMethod = r.PaymentMethod,
                TransactionCode = r.TransactionCode,
                RefundedAt = r.RefundedAt
            })
            .FirstOrDefaultAsync();
    }

    public async Task<bool> CompleteRefundAsync(int refundId, CompleteRefundDto dto)
    {
        var refund = await _context.Refunds
            .Include(r => r.ReturnRequest)
            .FirstOrDefaultAsync(r => r.RefundId == refundId);

        if (refund == null)
            return false;

        if (refund.Status != "Pending")
            return false;

        refund.Status = "Completed";
        refund.TransactionCode = dto.TransactionCode;
        refund.RefundedAt = DateTime.Now;

        refund.ReturnRequest.Status = "Refunded";

        await _context.SaveChangesAsync();

        return true;
    }
}