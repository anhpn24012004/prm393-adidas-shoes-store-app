using AdidasShoesStore.Api.DTOs.Returns;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IReturnRequestService
{
    Task<List<ReturnRequestDto>> GetAllAsync();
    Task<List<ReturnRequestDto>> GetByUserIdAsync(int userId);
    Task<ReturnRequestDto?> GetByUserIdAsync(int userId, int returnRequestId);
    Task<ReturnRequestDto?> GetByIdAsync(int returnRequestId);
    Task<ReturnRequestDto?> CreateAsync(int userId, CreateReturnRequestDto dto);
    Task<ReturnRequestDto?> ApproveAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto);
    Task<ReturnRequestDto?> RejectAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto);
    Task<ReturnRequestDto?> UpdateShippingInfoAsync(int userId, int returnRequestId, ReturnShippingInfoDto dto);
    Task<ReturnRequestDto?> MarkReceivedAsync(int returnRequestId, int adminUserId, ReviewReturnRequestDto dto);
    Task<ReturnRequestDto?> InspectAsync(int returnRequestId, int adminUserId, InspectReturnRequestDto dto);
    Task<ReturnRequestDto?> MarkRefundedAsync(int returnRequestId, int adminUserId, MarkRefundedReturnRequestDto dto);
}
