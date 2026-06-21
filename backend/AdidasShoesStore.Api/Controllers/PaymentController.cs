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

            return Ok(new
            {
                paymentUrl = result.Data!.PaymentUrl
            });
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

            return Ok(new
            {
                success = result.Success,
                orderCode = result.OrderCode,
                message = result.Message
            });
        }

        [Authorize]
        [HttpPost("paypal/create")]
        public async Task<IActionResult> CreatePayPalPayment(CreatePayPalPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _paymentService.CreatePayPalPaymentUrlAsync(
                userId,
                dto
            );

            if (!result.Success)
            {
                if (result.ErrorType == "NotFound")
                {
                    return NotFound(new { message = result.Error });
                }

                return BadRequest(new { message = result.Error });
            }

            return Ok(new
            {
                approvalUrl = result.Data!.ApprovalUrl,
                paypalOrderId = result.Data.PayPalOrderId
            });
        }

        [AllowAnonymous]
        [HttpGet("paypal-return")]
        public async Task<IActionResult> PayPalReturn()
        {
            var queryParameters = Request.Query.ToDictionary(
                p => p.Key,
                p => p.Value.ToString()
            );

            var result = await _paymentService.ProcessPayPalReturnAsync(queryParameters);

            return Ok(new
            {
                success = result.Success,
                orderCode = result.OrderCode,
                message = result.Message
            });
        }

        [AllowAnonymous]
        [HttpGet("paypal-cancel")]
        public async Task<IActionResult> PayPalCancel()
        {
            var queryParameters = Request.Query.ToDictionary(
                p => p.Key,
                p => p.Value.ToString()
            );

            var result = await _paymentService.ProcessPayPalCancelAsync(queryParameters);

            return Ok(new
            {
                success = result.Success,
                orderCode = result.OrderCode,
                message = result.Message
            });
        }

        [Authorize]
        [HttpPost("qr/create")]
        public async Task<IActionResult> CreateQrPayment(CreateQrPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _paymentService.CreateQrPaymentAsync(userId, dto);

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

        [Authorize]
        [HttpPost("qr/confirm")]
        public async Task<IActionResult> ConfirmQrPayment(ConfirmQrPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _paymentService.ConfirmQrPaymentAsync(userId, dto);

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

        [Authorize]
        [HttpPost("visa/pay")]
        public async Task<IActionResult> PayWithVisa(CreateVisaPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _paymentService.PayWithVisaAsync(userId, dto);

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

        [Authorize]
        [HttpGet("order/{orderId:int}/status")]
        public async Task<IActionResult> GetPaymentStatus(int orderId)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var status = await _paymentService.GetPaymentStatusAsync(
                userId,
                orderId
            );

            if (status == null)
            {
                return NotFound(new { message = "Payment not found" });
            }

            return Ok(status);
        }

        private bool TryGetUserId(out int userId)
        {
            var value = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            return int.TryParse(value, out userId);
        }
    }
}
