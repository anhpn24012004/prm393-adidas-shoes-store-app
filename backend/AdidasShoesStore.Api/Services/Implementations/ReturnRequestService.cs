using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Returns;
using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Services.Implementations;

public class ReturnRequestService : IReturnRequestService
{
    private static readonly string[] ActiveStatuses =
    {
        "Pending",
        "Approved",
        "ReturnShipped",
        "ReturnReceived",
        "Refunded"
    };

    private readonly AdidasShoesStoreContext _context;
    private readonly ShopReturnAddressSettings _shopReturnAddress;
    private readonly INotificationService _notificationService;
    private readonly IInventoryRealtimeService _inventoryRealtimeService;
    private readonly ILogger<ReturnRequestService> _logger;

    public ReturnRequestService(
        AdidasShoesStoreContext context,
        IOptions<ShopReturnAddressSettings> shopReturnAddress,
        INotificationService notificationService,
        IInventoryRealtimeService inventoryRealtimeService,
        ILogger<ReturnRequestService> logger)
    {
        _context = context;
        _shopReturnAddress = shopReturnAddress.Value;
        _notificationService = notificationService;
        _inventoryRealtimeService = inventoryRealtimeService;
        _logger = logger;
    }

    public async Task<List<ReturnRequestDto>> GetAllAsync()
    {
        var requests = await BaseQuery()
            .OrderByDescending(r => r.RequestedAt)
            .ToListAsync();

        return requests.Select(Map).ToList();
    }

    public async Task<List<ReturnRequestDto>> GetByUserIdAsync(int userId)
    {
        var requests = await BaseQuery()
            .Where(r => r.UserId == userId)
            .OrderByDescending(r => r.RequestedAt)
            .ToListAsync();

        return requests.Select(Map).ToList();
    }

    public async Task<ReturnRequestDto?> GetByUserIdAsync(int userId, int returnRequestId)
    {
        var request = await BaseQuery()
            .FirstOrDefaultAsync(r => r.UserId == userId && r.ReturnRequestId == returnRequestId);

        return request == null ? null : Map(request);
    }

    public async Task<ReturnRequestDto?> GetByIdAsync(int returnRequestId)
    {
        var request = await BaseQuery()
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);

        return request == null ? null : Map(request);
    }

    public async Task<ReturnRequestDto?> CreateAsync(int userId, CreateReturnRequestDto dto)
    {
        if (dto.OrderId <= 0 ||
            dto.Items.Count == 0 ||
            string.IsNullOrWhiteSpace(dto.Reason) ||
            string.IsNullOrWhiteSpace(dto.BankName) ||
            string.IsNullOrWhiteSpace(dto.BankAccountNumber) ||
            string.IsNullOrWhiteSpace(dto.BankAccountName))
        {
            return null;
        }

        var order = await _context.Orders
            .Include(o => o.Payment)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.ReturnItems)
                    .ThenInclude(ri => ri.ReturnRequest)
            .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId && o.UserId == userId);

        if (order == null ||
            order.Payment == null ||
            !IsDeliveredOrCompleted(order.Status) ||
            !string.Equals(order.Payment.Status, "Success", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        var selectedOrderItemIds = dto.Items.Select(i => i.OrderItemId).Distinct().ToList();
        if (selectedOrderItemIds.Count != dto.Items.Count)
        {
            return null;
        }

        var returnItems = new List<ReturnItem>();
        decimal requestedAmount = 0;

        foreach (var itemDto in dto.Items)
        {
            var orderItem = order.OrderItems.FirstOrDefault(oi => oi.OrderItemId == itemDto.OrderItemId);
            if (orderItem == null || itemDto.Quantity <= 0)
            {
                return null;
            }

            var alreadyActiveQuantity = orderItem.ReturnItems
                .Where(ri => ActiveStatuses.Contains(ri.ReturnRequest.Status))
                .Sum(ri => ri.Quantity);

            var availableQuantity = orderItem.Quantity - alreadyActiveQuantity;
            if (itemDto.Quantity > availableQuantity)
            {
                return null;
            }

            var refundAmount = itemDto.Quantity * orderItem.UnitPrice;
            requestedAmount += refundAmount;

            returnItems.Add(new ReturnItem
            {
                OrderItemId = orderItem.OrderItemId,
                Quantity = itemDto.Quantity,
                UnitPrice = orderItem.UnitPrice,
                RefundAmount = refundAmount,
                Reason = string.IsNullOrWhiteSpace(itemDto.Reason) ? null : itemDto.Reason.Trim()
            });
        }

        var request = new ReturnRequest
        {
            OrderId = order.OrderId,
            UserId = userId,
            RequestCode = GenerateRequestCode(),
            Reason = dto.Reason.Trim(),
            CustomerNote = string.IsNullOrWhiteSpace(dto.CustomerNote) ? null : dto.CustomerNote.Trim(),
            BankName = dto.BankName.Trim(),
            BankAccountNumber = dto.BankAccountNumber.Trim(),
            BankAccountName = dto.BankAccountName.Trim(),
            RequestedAmount = requestedAmount,
            Status = "Pending",
            RequestedAt = DateTime.Now,
            ReturnItems = returnItems
        };

        _context.ReturnRequests.Add(request);
        await _context.SaveChangesAsync();

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            service => service.CreateForRoleAsync(
                "Admin",
                "New return request",
                $"Return request for order {order.OrderCode} was submitted.",
                NotificationTypes.ReturnRequestCreated,
                relatedOrderId: order.OrderId,
                relatedReturnRequestId: request.ReturnRequestId));

        return await GetByUserIdAsync(userId, request.ReturnRequestId);
    }

    public async Task<ReturnRequestDto?> ApproveAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto)
    {
        var request = await _context.ReturnRequests
            .Include(r => r.Order)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);
        if (request == null || request.Status != "Pending")
        {
            return null;
        }

        request.Status = "Approved";
        request.ApprovedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = Clean(dto.AdminNote);

        await _context.SaveChangesAsync();

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            service => service.CreateForUserAsync(
                request.UserId,
                "Return request approved",
                $"Your return request for order {request.Order.OrderCode} was approved.",
                NotificationTypes.ReturnApproved,
                relatedOrderId: request.OrderId,
                relatedReturnRequestId: request.ReturnRequestId));

        return await GetByIdAsync(returnRequestId);
    }

    public async Task<ReturnRequestDto?> RejectAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.AdminNote))
        {
            return null;
        }

        var request = await _context.ReturnRequests
            .Include(r => r.Order)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);
        if (request == null || (request.Status != "Pending" && request.Status != "ReturnReceived"))
        {
            return null;
        }

        request.Status = "Rejected";
        request.RejectedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = dto.AdminNote.Trim();

        await _context.SaveChangesAsync();

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            service => service.CreateForUserAsync(
                request.UserId,
                "Return request rejected",
                $"Your return request for order {request.Order.OrderCode} was rejected.",
                NotificationTypes.ReturnRejected,
                relatedOrderId: request.OrderId,
                relatedReturnRequestId: request.ReturnRequestId));

        return await GetByIdAsync(returnRequestId);
    }

    public async Task<ReturnRequestDto?> UpdateShippingInfoAsync(int userId, int returnRequestId, ReturnShippingInfoDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.ReturnCarrier) ||
            string.IsNullOrWhiteSpace(dto.ReturnTrackingCode))
        {
            return null;
        }

        var request = await _context.ReturnRequests
            .Include(r => r.Order)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId && r.UserId == userId);

        if (request == null || request.Status != "Approved")
        {
            return null;
        }

        request.Status = "ReturnShipped";
        request.ReturnCarrier = dto.ReturnCarrier.Trim();
        request.ReturnTrackingCode = dto.ReturnTrackingCode.Trim();
        request.ReturnShipmentNote = Clean(dto.ReturnShipmentNote);
        request.ReturnShippedAt = DateTime.Now;

        await _context.SaveChangesAsync();

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            async service =>
            {
                await service.CreateForRoleAsync(
                    "Admin",
                    "Return shipment submitted",
                    $"Customer submitted return tracking for order {request.Order.OrderCode}.",
                    NotificationTypes.ReturnShipped,
                    relatedOrderId: request.OrderId,
                    relatedReturnRequestId: request.ReturnRequestId);

                await service.CreateForRoleAsync(
                    "Admin",
                    "Returned item waiting for shop confirmation",
                    $"Returned item for order {request.Order.OrderCode} is waiting for shop confirmation.",
                    NotificationTypes.ReturnWaitingConfirmation,
                    relatedOrderId: request.OrderId,
                    relatedReturnRequestId: request.ReturnRequestId);
            });

        return await GetByUserIdAsync(userId, returnRequestId);
    }

    public async Task<ReturnRequestDto?> MarkReceivedAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto)
    {
        var request = await _context.ReturnRequests
            .Include(r => r.Order)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);
        if (request == null || (request.Status != "ReturnShipped" && request.Status != "Approved"))
        {
            return null;
        }

        request.Status = "ReturnReceived";
        request.ReturnReceivedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = Clean(dto.AdminNote) ?? request.AdminNote;

        await _context.SaveChangesAsync();

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            service => service.CreateForUserAsync(
                request.UserId,
                "Returned item received",
                $"Shop has received your returned item for order {request.Order.OrderCode}.",
                NotificationTypes.ReturnReceived,
                relatedOrderId: request.OrderId,
                relatedReturnRequestId: request.ReturnRequestId));

        return await GetByIdAsync(returnRequestId);
    }

    public async Task<ReturnRequestDto?> InspectAsync(int returnRequestId, int adminUserId, InspectReturnRequestDto dto)
    {
        var request = await _context.ReturnRequests
            .Include(r => r.ReturnItems)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);

        if (request == null || request.Status != "ReturnReceived")
        {
            return null;
        }

        var returnedQuantity = request.ReturnItems.Sum(i => i.Quantity);
        if (dto.RestockQuantity < 0 || dto.RestockQuantity > returnedQuantity)
        {
            return null;
        }

        request.IsRestockable = dto.IsRestockable;
        request.RestockQuantity = dto.IsRestockable ? dto.RestockQuantity : 0;
        request.InspectionNote = Clean(dto.InspectionNote);
        request.ProcessedByAdminId = adminUserId;

        await _context.SaveChangesAsync();
        return await GetByIdAsync(returnRequestId);
    }

    public async Task<ReturnRequestDto?> MarkRefundedAsync(
        int returnRequestId,
        int adminUserId,
        MarkRefundedReturnRequestDto dto)
    {
        var request = await _context.ReturnRequests
            .Include(r => r.Order)
                .ThenInclude(o => o.Payment)
            .Include(r => r.ReturnItems)
                .ThenInclude(ri => ri.OrderItem)
                    .ThenInclude(oi => oi.Variant)
            .FirstOrDefaultAsync(r => r.ReturnRequestId == returnRequestId);

        if (request == null ||
            request.Status != "ReturnReceived" ||
            request.Order.Payment == null ||
            request.IsRestockable != true)
        {
            return null;
        }

        request.Status = "Refunded";
        request.RefundedAt = DateTime.Now;
        request.ProcessedByAdminId = adminUserId;
        request.AdminNote = Clean(dto.AdminNote) ?? request.AdminNote;
        request.RefundTransactionNote = Clean(dto.RefundTransactionNote);

        request.Order.Payment.Status = IsFullOrderRefund(request) ? "Refunded" : "PartiallyRefunded";

        var restoredVariants = new List<(int ProductId, int VariantId)>();
        var restockLeft = request.RestockQuantity ?? 0;
        if (request.IsRestockable == true && restockLeft > 0)
        {
            foreach (var item in request.ReturnItems.OrderBy(i => i.ReturnItemId))
            {
                if (restockLeft <= 0)
                {
                    break;
                }

                var quantity = Math.Min(item.Quantity, restockLeft);
                item.OrderItem.Variant.StockQuantity = (item.OrderItem.Variant.StockQuantity ?? 0) + quantity;
                restoredVariants.Add((item.OrderItem.Variant.ProductId, item.OrderItem.Variant.VariantId));
                restockLeft -= quantity;
            }
        }

        if (request.Order.Payment.Status == "Refunded")
        {
            request.Order.Status = "Refunded";
        }

        await _context.SaveChangesAsync();

        await _inventoryRealtimeService.NotifyStockChangedAsync(restoredVariants, "ReturnRestocked");

        await NotificationDispatch.TryAsync(
            _notificationService,
            _logger,
            service => service.CreateForUserAsync(
                request.UserId,
                "Return/refund completed",
                $"Refund for returned item in order {request.Order.OrderCode} has been completed.",
                NotificationTypes.ReturnRefunded,
                relatedOrderId: request.OrderId,
                relatedReturnRequestId: request.ReturnRequestId));

        return await GetByIdAsync(returnRequestId);
    }

    private IQueryable<ReturnRequest> BaseQuery()
    {
        return _context.ReturnRequests
            .AsNoTracking()
            .Include(r => r.Order)
                .ThenInclude(o => o.Payment)
            .Include(r => r.User)
            .Include(r => r.ProcessedByAdmin)
            .Include(r => r.ReturnItems)
                .ThenInclude(ri => ri.OrderItem)
                    .ThenInclude(oi => oi.Variant)
                        .ThenInclude(v => v.Product);
    }

    private ReturnRequestDto Map(ReturnRequest request)
    {
        return new ReturnRequestDto
        {
            ReturnRequestId = request.ReturnRequestId,
            RequestCode = request.RequestCode,
            OrderId = request.OrderId,
            OrderCode = request.Order.OrderCode,
            UserId = request.UserId,
            CustomerName = request.User.FullName,
            CustomerEmail = request.User.Email,
            CustomerPhone = request.User.Phone,
            Reason = request.Reason,
            CustomerNote = request.CustomerNote,
            Status = request.Status,
            RequestedAt = request.RequestedAt,
            AdminNote = request.AdminNote,
            BankName = request.BankName,
            BankAccountNumber = request.BankAccountNumber,
            BankAccountName = request.BankAccountName,
            RequestedAmount = request.RequestedAmount,
            ApprovedAt = request.ApprovedAt,
            RejectedAt = request.RejectedAt,
            ReturnCarrier = request.ReturnCarrier,
            ReturnTrackingCode = request.ReturnTrackingCode,
            ReturnShipmentNote = request.ReturnShipmentNote,
            ReturnShippedAt = request.ReturnShippedAt,
            ReturnReceivedAt = request.ReturnReceivedAt,
            InspectionNote = request.InspectionNote,
            IsRestockable = request.IsRestockable,
            RestockQuantity = request.RestockQuantity,
            RefundTransactionNote = request.RefundTransactionNote,
            RefundedAt = request.RefundedAt,
            ProcessedByAdminId = request.ProcessedByAdminId,
            ProcessedByAdminName = request.ProcessedByAdmin?.FullName,
            PaymentMethod = request.Order.Payment?.PaymentMethod,
            PaymentStatus = request.Order.Payment?.Status,
            OrderStatus = request.Order.Status,
            Items = request.ReturnItems.Select(item => new ReturnItemDto
            {
                ReturnItemId = item.ReturnItemId,
                OrderItemId = item.OrderItemId,
                ProductId = item.OrderItem.Variant.ProductId,
                ProductVariantId = item.OrderItem.VariantId,
                ProductName = item.OrderItem.ProductName,
                Size = item.OrderItem.Size,
                Color = item.OrderItem.Color,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice,
                RefundAmount = item.RefundAmount
            }).ToList(),
            ShopReturnAddress = new ShopReturnAddressDto
            {
                ShopName = _shopReturnAddress.ShopName,
                Phone = _shopReturnAddress.Phone,
                Address = _shopReturnAddress.Address,
                WardName = _shopReturnAddress.WardName,
                DistrictName = _shopReturnAddress.DistrictName,
                ProvinceName = _shopReturnAddress.ProvinceName
            }
        };
    }

    private static bool IsDeliveredOrCompleted(string status)
    {
        return string.Equals(status, "Delivered", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(status, "Completed", StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsFullOrderRefund(ReturnRequest request)
    {
        var refundedAmount = request.ReturnItems.Sum(i => i.RefundAmount);
        return refundedAmount >= request.Order.FinalAmount;
    }

    private static string GenerateRequestCode()
    {
        return $"RTR{DateTime.Now:yyyyMMddHHmmssfff}{Guid.NewGuid():N}"[..24];
    }

    private static string? Clean(string? value)
    {
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }
}
