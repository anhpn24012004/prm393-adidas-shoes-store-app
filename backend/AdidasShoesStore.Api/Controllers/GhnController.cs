using AdidasShoesStore.Api.DTOs.Ghn;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/ghn")]
    public class GhnController : ControllerBase
    {
        private readonly IGhnService _ghnService;

        public GhnController(IGhnService ghnService)
        {
            _ghnService = ghnService;
        }

        [HttpGet("provinces")]
        public async Task<IActionResult> GetProvinces()
        {
            var result = await _ghnService.GetProvincesAsync();

            return result.Success
                ? Ok(result.Data)
                : BadRequest(new { message = result.Message });
        }

        [HttpGet("districts")]
        public async Task<IActionResult> GetDistricts([FromQuery] int provinceId)
        {
            var result = await _ghnService.GetDistrictsAsync(provinceId);

            return result.Success
                ? Ok(result.Data)
                : BadRequest(new { message = result.Message });
        }

        [HttpGet("wards")]
        public async Task<IActionResult> GetWards([FromQuery] int districtId)
        {
            var result = await _ghnService.GetWardsAsync(districtId);

            return result.Success
                ? Ok(result.Data)
                : BadRequest(new { message = result.Message });
        }

        [HttpPost("calculate-fee")]
        public async Task<IActionResult> CalculateFee(GhnCalculateFeeRequestDto dto)
        {
            var result = await _ghnService.CalculateFeeAsync(dto);

            return result.Success
                ? Ok(result.Data)
                : BadRequest(new { message = result.Message });
        }

        [HttpGet("orders/{ghnOrderCode}/tracking")]
        public async Task<IActionResult> GetTracking(string ghnOrderCode)
        {
            var result = await _ghnService.GetTrackingAsync(ghnOrderCode);

            return result.Success
                ? Ok(result.Data)
                : BadRequest(new { message = result.Message });
        }
    }
}
