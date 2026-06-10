using AdidasShoesStore.Api.DTOs.Returns;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IReturnRequestService
{
    Task<List<ReturnRequestDto>> GetByUserIdAsync(int userId);
    Task<ReturnRequestDto?> CreateAsync(CreateReturnRequestDto dto);
    Task<bool> ApproveAsync(int returnRequestId, string? adminNote);
    Task<bool> RejectAsync(int returnRequestId, string? adminNote);
}