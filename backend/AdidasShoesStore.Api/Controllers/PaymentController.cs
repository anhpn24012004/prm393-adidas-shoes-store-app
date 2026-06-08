using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AdidasShoesStore.Api.Controllers
{
    [ApiController]
    [Route("api/payments")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(IPaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [Authorize]
        [HttpPost("vnpay/create")]
        public async Task<IActionResult> CreateVnPayPayment(CreateVnPayPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            var result = await _paymentService.CreateVnPayPaymentUrlAsync(
                userId,
                dto,
                ipAddress
            );

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return Ok(result.Data);
        }

        [AllowAnonymous]
        [HttpGet("vnpay-return")]
        public async Task<IActionResult> VnPayReturn()
        {
            var queryParameters = Request.Query.ToDictionary(
                p => p.Key,
                p => p.Value.ToString()
            );

            var result = await _paymentService.ProcessVnPayReturnAsync(queryParameters);

            return Ok(result);
        }

        private bool TryGetUserId(out int userId)
        {
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            return int.TryParse(value, out userId);
        }
    }
}
