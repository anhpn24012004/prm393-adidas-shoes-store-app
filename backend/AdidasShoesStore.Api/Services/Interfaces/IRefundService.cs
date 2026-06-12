using AdidasShoesStore.Api.DTOs.Refunds;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IRefundService
{
    Task<List<RefundDto>> GetAllAsync();
    Task<List<RefundDto>> GetByOrderIdAsync(int orderId);
    Task<RefundDto?> GetByReturnRequestIdAsync(int returnRequestId);
    Task<bool> CompleteRefundAsync(int refundId, CompleteRefundDto dto);
}