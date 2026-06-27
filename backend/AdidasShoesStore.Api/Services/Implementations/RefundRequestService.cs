using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.RefundRequests;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

namespace AdidasShoesStore.Api.Services.Implementations;

public class RefundRequestService : IRefundRequestService
{
    private static readonly string[] AllowedPaymentMethods =
    {
        "SEPAY",
        "VNPAY",
        "PAYPAL"
    };

    private readonly AdidasShoesStoreContext _context;

    public RefundRequestService(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    public async Task<RefundRequestDto?> CreateAsync(int userId, CreateRefundRequestDto dto)
    {
        if (dto.OrderId <= 0 ||
            string.IsNullOrWhiteSpace(dto.Reason) ||
            string.IsNullOrWhiteSpace(dto.BankName) ||
            string.IsNullOrWhiteSpace(dto.BankAccountNumber) ||
            string.IsNullOrWhiteSpace(dto.BankAccountName) ||
            dto.RequestedAmount <= 0)
        {
            return null;
        }

        var order = await _context.Orders
            .Include(o => o.Payment)
            .Include(o => o.Shipment)
            .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId && o.UserId == userId);

        if (order == null || order.Payment == null)
        {
            return null;
        }

        var paymentMethod = order.Payment.PaymentMethod?.Trim().ToUpperInvariant() ?? string.Empty;
        var paymentStatus = order.Payment.Status?.Trim() ?? string.Empty;

        if (!AllowedPaymentMethods.Contains(paymentMethod) ||
            !string.Equals(paymentStatus, "Success", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        if (!string.Equals(order.Status, "Paid", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(order.Status, "Processing", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        if (order.Shipment != null)
        {
            return null;
        }

        if (dto.RequestedAmount > order.FinalAmount)
        {
            return null;
        }

        var hasPendingRequest = await _context.RefundRequests
            .AnyAsync(r =>
                r.OrderId == dto.OrderId &&
                r.UserId == userId &&
                r.Status == "Pending");

        if (hasPendingRequest)
        {
            return null;
        }

        var request = new RefundRequest
        {
            OrderId = order.OrderId,
            UserId = userId,
            RequestCode = GenerateRequestCode(),
            Reason = dto.Reason.Trim(),
            RequestedAmount = dto.RequestedAmount,
            BankName = dto.BankName.Trim(),
            BankAccountNumber = dto.BankAccountNumber.Trim(),
            BankAccountName = dto.BankAccountName.Trim(),
            CustomerNote = string.IsNullOrWhiteSpace(dto.CustomerNote) ? null : dto.CustomerNote.Trim(),
            Status = "Pending",
            CreatedAt = DateTime.Now,
            ProofImageUrl = string.IsNullOrWhiteSpace(dto.ProofImageUrl) ? null : dto.ProofImageUrl.Trim()
        };

        _context.RefundRequests.Add(request);
        await _context.SaveChangesAsync();

        return await GetMyByIdAsync(userId, request.RefundRequestId);
    }

    public async Task<List<RefundRequestDto>> GetMyAsync(int userId)
    {
        return await _context.RefundRequests
            .AsNoTracking()
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.CreatedAt)
            .Select(MapRefundRequestDto())
            .ToListAsync();
    }

    public async Task<RefundRequestDto?> GetMyByIdAsync(int userId, int refundRequestId)
    {
        return await _context.RefundRequests
            .AsNoTracking()
            .Where(r => r.UserId == userId && r.RefundRequestId == refundRequestId)
            .Select(MapRefundRequestDto())
            .FirstOrDefaultAsync();
    }

    public async Task<List<AdminRefundRequestDetailDto>> GetAdminListAsync()
    {
        return await _context.RefundRequests
            .AsNoTracking()
            .OrderByDescending(r => r.CreatedAt)
            .Select(MapAdminRefundRequestDto())
            .ToListAsync();
    }

    public async Task<AdminRefundRequestDetailDto?> GetAdminByIdAsync(int refundRequestId)
    {
        return await _context.RefundRequests
            .AsNoTracking()
            .Where(r => r.RefundRequestId == refundRequestId)
            .Select(MapAdminRefundRequestDto())
            .FirstOrDefaultAsync();
    }

    public async Task<AdminRefundRequestDetailDto?> ApproveAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto)
    {
        var request = await _context.RefundRequests
            .FirstOrDefaultAsync(r => r.RefundRequestId == refundRequestId);

        if (request == null)
        {
            throw new InvalidOperationException("Refund request not found.");
        }

        if (!string.Equals(request.Status, "Pending", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Refund request must be pending before approving.");
        }

        request.Status = "Approved";
        request.ApprovedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = string.IsNullOrWhiteSpace(dto.AdminNote) ? request.AdminNote : dto.AdminNote.Trim();

        await _context.SaveChangesAsync();

        return await GetAdminByIdAsync(refundRequestId);
    }

    public async Task<AdminRefundRequestDetailDto?> RejectAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto)
    {
        var request = await _context.RefundRequests
            .FirstOrDefaultAsync(r => r.RefundRequestId == refundRequestId);

        if (request == null)
        {
            throw new InvalidOperationException("Refund request not found.");
        }

        if (!string.Equals(request.Status, "Pending", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Refund request must be pending before rejecting.");
        }

        if (string.IsNullOrWhiteSpace(dto.AdminNote))
        {
            throw new InvalidOperationException("Reject reason is required.");
        }

        request.Status = "Rejected";
        request.RejectedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = dto.AdminNote.Trim();

        await _context.SaveChangesAsync();

        return await GetAdminByIdAsync(refundRequestId);
    }

    public async Task<AdminRefundRequestDetailDto?> MarkRefundedAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto)
    {
        var request = await _context.RefundRequests
            .Include(r => r.Order)
                .ThenInclude(o => o.Payment)
            .Include(r => r.Order)
                .ThenInclude(o => o.Shipment)
            .Include(r => r.Order)
                .ThenInclude(o => o.OrderItems)
                    .ThenInclude(i => i.Variant)
            .FirstOrDefaultAsync(r => r.RefundRequestId == refundRequestId);

        if (request == null)
        {
            throw new InvalidOperationException("Refund request not found.");
        }

        if (string.Equals(request.Status, "Pending", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Refund request must be approved before marking as refunded.");
        }

        if (!string.Equals(request.Status, "Approved", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Refund request cannot be marked as refunded.");
        }

        if (request.Order.Payment == null)
        {
            throw new InvalidOperationException("Order payment is missing.");
        }

        if (!string.Equals(request.Order.Payment.Status, "Success", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(request.Order.Payment.Status, "Refunded", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Payment status is not eligible for manual refund completion.");
        }

        request.Status = "Refunded";
        request.RefundedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = string.IsNullOrWhiteSpace(dto.AdminNote) ? request.AdminNote : dto.AdminNote.Trim();
        request.RefundTransactionNote = string.IsNullOrWhiteSpace(dto.RefundTransactionNote)
            ? request.RefundTransactionNote
            : dto.RefundTransactionNote.Trim();

        request.Order.Payment.Status = "Refunded";

        if (request.Order.Shipment == null)
        {
            foreach (var item in request.Order.OrderItems)
            {
                if (item.Variant != null)
                {
                    item.Variant.StockQuantity = (item.Variant.StockQuantity ?? 0) + item.Quantity;
                }
            }
        }

        request.Order.Status = "Cancelled";

        await _context.SaveChangesAsync();

        return await GetAdminByIdAsync(refundRequestId);
    }

    private static string GenerateRequestCode()
    {
        return $"RFR{DateTime.Now:yyyyMMddHHmmssfff}{Guid.NewGuid():N}"[..24];
    }

    private static Expression<Func<RefundRequest, RefundRequestDto>> MapRefundRequestDto()
    {
        return r => new RefundRequestDto
        {
            RefundRequestId = r.RefundRequestId,
            OrderId = r.OrderId,
            UserId = r.UserId,
            RequestCode = r.RequestCode,
            Reason = r.Reason,
            RequestedAmount = r.RequestedAmount,
            BankName = r.BankName,
            BankAccountNumber = r.BankAccountNumber,
            BankAccountName = r.BankAccountName,
            CustomerNote = r.CustomerNote,
            Status = r.Status,
            CreatedAt = r.CreatedAt,
            ApprovedAt = r.ApprovedAt,
            RejectedAt = r.RejectedAt,
            RefundedAt = r.RefundedAt,
            AdminNote = r.AdminNote,
            ProofImageUrl = r.ProofImageUrl,
            RefundTransactionNote = r.RefundTransactionNote
        };
    }

    private static Expression<Func<RefundRequest, AdminRefundRequestDetailDto>> MapAdminRefundRequestDto()
    {
        return r => new AdminRefundRequestDetailDto
        {
            RefundRequestId = r.RefundRequestId,
            OrderId = r.OrderId,
            UserId = r.UserId,
            RequestCode = r.RequestCode,
            Reason = r.Reason,
            RequestedAmount = r.RequestedAmount,
            BankName = r.BankName,
            BankAccountNumber = r.BankAccountNumber,
            BankAccountName = r.BankAccountName,
            CustomerNote = r.CustomerNote,
            Status = r.Status,
            CreatedAt = r.CreatedAt,
            ApprovedAt = r.ApprovedAt,
            RejectedAt = r.RejectedAt,
            RefundedAt = r.RefundedAt,
            AdminNote = r.AdminNote,
            ProofImageUrl = r.ProofImageUrl,
            RefundTransactionNote = r.RefundTransactionNote,
            OrderCode = r.Order.OrderCode,
            CustomerName = r.User.FullName,
            CustomerEmail = r.User.Email,
            CustomerPhone = r.User.Phone,
            PaymentMethod = r.Order.Payment == null ? string.Empty : r.Order.Payment.PaymentMethod,
            PaymentStatus = r.Order.Payment == null ? string.Empty : r.Order.Payment.Status,
            OrderStatus = r.Order.Status,
            FinalAmount = r.Order.FinalAmount,
            ShipmentId = r.Order.Shipment == null ? null : r.Order.Shipment.ShipmentId,
            ShipmentStatus = r.Order.Shipment == null ? null : r.Order.Shipment.Status,
            TrackingCode = r.Order.Shipment == null ? null : r.Order.Shipment.TrackingCode,
            GhnOrderCode = r.Order.Shipment == null ? null : r.Order.Shipment.GhnOrderCode,
            PaidAt = r.Order.Payment == null ? null : r.Order.Payment.PaidAt,
            ProcessedByAdminId = r.ProcessedByAdminId,
            ProcessedByAdminName = r.ProcessedByAdmin == null ? null : r.ProcessedByAdmin.FullName,
            ProcessedByAdminEmail = r.ProcessedByAdmin == null ? null : r.ProcessedByAdmin.Email
        };
    }
}
