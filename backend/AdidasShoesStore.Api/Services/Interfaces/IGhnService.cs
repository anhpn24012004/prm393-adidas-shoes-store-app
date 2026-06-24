using AdidasShoesStore.Api.DTOs.Ghn;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public interface IGhnService
    {
        Task<GhnApiResponseDto<List<GhnProvinceDto>>> GetProvincesAsync();

        Task<GhnApiResponseDto<List<GhnDistrictDto>>> GetDistrictsAsync(int provinceId);

        Task<GhnApiResponseDto<List<GhnWardDto>>> GetWardsAsync(int districtId);

        Task<GhnApiResponseDto<GhnCalculateFeeResponseDto>> CalculateFeeAsync(
            GhnCalculateFeeRequestDto request
        );

        Task<GhnApiResponseDto<GhnCreateOrderResponseDto>> CreateOrderAsync(
            GhnCreateOrderRequestDto request
        );

        Task<GhnApiResponseDto<GhnTrackingDto>> GetTrackingAsync(string ghnOrderCode);
    }
}
