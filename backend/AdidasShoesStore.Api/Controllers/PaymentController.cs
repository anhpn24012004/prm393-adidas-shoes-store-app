using System.Security.Claims;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Globalization;

namespace AdidasShoesStore.Api.Controllers
{
    [ApiController]
    [Route("api/payments")]
    public class PaymentController : ControllerBase
    {
        private readonly IPaymentService _paymentService;
        private readonly ISePayService _sePayService;
        private readonly IConfiguration _configuration;
        private readonly ILogger<PaymentController> _logger;

        public PaymentController(
            IPaymentService paymentService,
            ISePayService sePayService,
            IConfiguration configuration,
            ILogger<PaymentController> logger)
        {
            _paymentService = paymentService;
            _sePayService = sePayService;
            _configuration = configuration;
            _logger = logger;
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

            return Redirect(BuildPaymentResultUrl(result.OrderId, result.Success));
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

            return Redirect(BuildPaymentResultUrl(result.OrderId, result.Success));
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

            return Redirect(BuildPaymentResultUrl(result.OrderId, false));
        }

        [Authorize]
        [HttpPost("qr/create")]
        public IActionResult CreateQrPayment()
        {
            return BadRequest(new
            {
                message = "QR payment is no longer supported. Please use SePay."
            });
        }

        [Authorize]
        [HttpPost("qr/confirm")]
        public IActionResult ConfirmQrPayment()
        {
            return BadRequest(new
            {
                message = "QR payment is no longer supported. Please use SePay."
            });
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("admin/qr/confirm")]
        public IActionResult AdminConfirmQrPayment()
        {
            return BadRequest(new
            {
                message = "QR payment is no longer supported. Please use SePay."
            });
        }

        [Authorize]
        [HttpPost("sepay/create")]
        public async Task<IActionResult> CreateSePayPayment(CreateSePayPaymentDto dto)
        {
            if (!TryGetUserId(out var userId))
            {
                return Unauthorized(new { message = "Invalid token" });
            }

            var result = await _sePayService.CreatePaymentAsync(userId, dto);
            if (!result.Success)
                return result.ErrorType == "NotFound"
                    ? NotFound(new { message = result.Error })
                    : BadRequest(new { message = result.Error });

            return Ok(result.Data);
        }

        [AllowAnonymous]
        [HttpPost("sepay/webhook")]
        public async Task<IActionResult> SePayWebhook()
        {
            try
            {
                _logger.LogInformation("===== SEPAY WEBHOOK CONTROLLER HIT =====");

                using var reader = new StreamReader(Request.Body);
                var rawBody = await reader.ReadToEndAsync();

                _logger.LogInformation("SePay webhook controller rawBody: {RawBody}", rawBody);

                var authorization = Request.Headers["Authorization"].FirstOrDefault();

                var result = await _sePayService.ProcessWebhookAsync(
                    rawBody,
                    authorization,
                    Request.Headers["X-SePay-Signature"].FirstOrDefault(),
                    Request.Headers["X-SePay-Timestamp"].FirstOrDefault()
                );

                if (!result.Success)
                {
                    _logger.LogWarning("SePay webhook failed: {Error}", result.Error);

                    return result.ErrorType == "Unauthorized"
                        ? Unauthorized(new { success = false, message = result.Error })
                        : BadRequest(new { success = false, message = result.Error });
                }

                return Ok(new { success = true });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "SePay webhook endpoint crashed");

                return StatusCode(500, new
                {
                    success = false,
                    message = ex.Message,
                    detail = ex.ToString()
                });
            }
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

        private string BuildPaymentResultUrl(int? orderId, bool success)
        {
            var baseUrl = _configuration["Frontend:PaymentResultUrl"];
            if (string.IsNullOrWhiteSpace(baseUrl))
            {
                baseUrl = "/payment-result";
            }

            var separator = baseUrl.Contains('?', StringComparison.Ordinal) ? "&" : "?";
            var status = success ? "success" : "failed";
            var orderIdValue = orderId?.ToString(CultureInfo.InvariantCulture) ?? "0";

            return $"{baseUrl}{separator}orderId={Uri.EscapeDataString(orderIdValue)}&status={status}";
        }
    }
}
