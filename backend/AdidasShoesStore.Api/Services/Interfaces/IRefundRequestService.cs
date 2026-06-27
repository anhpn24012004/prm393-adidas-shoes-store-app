using AdidasShoesStore.Api.DTOs.RefundRequests;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IRefundRequestService
{
    Task<RefundRequestDto?> CreateAsync(int userId, CreateRefundRequestDto dto);

    Task<List<RefundRequestDto>> GetMyAsync(int userId);

    Task<RefundRequestDto?> GetMyByIdAsync(int userId, int refundRequestId);

    Task<List<AdminRefundRequestDetailDto>> GetAdminListAsync();

    Task<AdminRefundRequestDetailDto?> GetAdminByIdAsync(int refundRequestId);

    Task<AdminRefundRequestDetailDto?> ApproveAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto);

    Task<AdminRefundRequestDetailDto?> RejectAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto);

    Task<AdminRefundRequestDetailDto?> MarkRefundedAsync(
        int refundRequestId,
        int adminUserId,
        ReviewRefundRequestDto dto);
}
