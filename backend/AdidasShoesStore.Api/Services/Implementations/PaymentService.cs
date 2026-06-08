using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class PaymentService : IPaymentService
    {
        private readonly AdidasShoesStoreContext _context;
        private readonly IConfiguration _configuration;
        private readonly VnPayHelper _vnPayHelper;
        private readonly IEmailService _emailService;

        public PaymentService(
            AdidasShoesStoreContext context,
            IConfiguration configuration,
            VnPayHelper vnPayHelper,
            IEmailService emailService)
        {
            _context = context;
            _configuration = configuration;
            _vnPayHelper = vnPayHelper;
            _emailService = emailService;
        }

        public async Task<PaymentServiceResult<VnPayPaymentResponseDto>> CreateVnPayPaymentUrlAsync(
            int userId,
            CreateVnPayPaymentDto dto,
            string ipAddress)
        {
            var config = GetVnPayConfig();

            if (config == null)
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail("VNPay configuration is missing");
            }

            var order = await _context.Orders
                .AsNoTracking()
                .Include(o => o.Payment)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == dto.OrderId &&
                    o.UserId == userId);

            if (order == null)
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Status != "PendingPayment")
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail(
                    "Only pending payment orders can be paid with VNPay"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "VNPAY", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail(
                    "Payment method must be VNPAY"
                );
            }

            var parameters = new Dictionary<string, string>
            {
                ["vnp_Version"] = "2.1.0",
                ["vnp_Command"] = "pay",
                ["vnp_TmnCode"] = config.TmnCode,
                ["vnp_Amount"] = ((long)Math.Round(order.FinalAmount * 100m)).ToString(),
                ["vnp_CreateDate"] = DateTime.Now.ToString("yyyyMMddHHmmss"),
                ["vnp_CurrCode"] = "VND",
                ["vnp_IpAddr"] = ipAddress,
                ["vnp_Locale"] = "vn",
                ["vnp_OrderInfo"] = $"Payment for order {order.OrderCode}",
                ["vnp_OrderType"] = "other",
                ["vnp_ReturnUrl"] = config.ReturnUrl,
                ["vnp_TxnRef"] = order.OrderCode
            };

            var paymentUrl = _vnPayHelper.CreatePaymentUrl(
                config.BaseUrl,
                config.HashSecret,
                parameters
            );

            return PaymentServiceResult<VnPayPaymentResponseDto>.Ok(new VnPayPaymentResponseDto
            {
                PaymentUrl = paymentUrl
            });
        }

        public async Task<VnPayPaymentResponseDto> ProcessVnPayReturnAsync(
            IReadOnlyDictionary<string, string> queryParameters)
        {
            var config = GetVnPayConfig();

            if (config == null)
            {
                return new VnPayPaymentResponseDto
                {
                    Success = false,
                    Message = "VNPay configuration is missing"
                };
            }

            var isValidHash = _vnPayHelper.ValidateSecureHash(
                config.HashSecret,
                queryParameters
            );

            queryParameters.TryGetValue("vnp_TxnRef", out var orderCode);
            queryParameters.TryGetValue("vnp_ResponseCode", out var responseCode);
            queryParameters.TryGetValue("vnp_TransactionNo", out var transactionNo);

            var order = await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderCode == orderCode);

            if (order == null || order.Payment == null)
            {
                return new VnPayPaymentResponseDto
                {
                    Success = false,
                    Message = "Order or payment not found"
                };
            }

            if (isValidHash && responseCode == "00")
            {
                order.Payment.Status = "Success";
                order.Payment.TransactionCode = transactionNo;
                order.Payment.PaidAt = DateTime.Now;
                order.Status = "Paid";

                await _context.SaveChangesAsync();

                var message = "Payment successful";

                try
                {
                    await _emailService.SendInvoiceEmailAsync(order);
                }
                catch
                {
                    message = "Payment successful, but invoice email could not be sent";
                }

                return new VnPayPaymentResponseDto
                {
                    Success = true,
                    OrderCode = order.OrderCode,
                    Message = message
                };
            }

            order.Payment.Status = "Failed";
            await _context.SaveChangesAsync();

            return new VnPayPaymentResponseDto
            {
                Success = false,
                OrderCode = order.OrderCode,
                Message = isValidHash ? "Payment failed" : "Invalid payment signature"
            };
        }

        public async Task<PaymentStatusDto?> GetPaymentStatusAsync(
            int userId,
            int orderId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId)
                .Select(o => o.Payment == null
                    ? null
                    : new PaymentStatusDto
                    {
                        OrderId = o.OrderId,
                        OrderCode = o.OrderCode,
                        OrderStatus = o.Status,
                        PaymentMethod = o.Payment.PaymentMethod,
                        PaymentStatus = o.Payment.Status,
                        Amount = o.Payment.Amount,
                        TransactionCode = o.Payment.TransactionCode,
                        PaidAt = o.Payment.PaidAt
                    })
                .FirstOrDefaultAsync();
        }

        private VnPayConfig? GetVnPayConfig()
        {
            var tmnCode = _configuration["VnPay:TmnCode"];
            var hashSecret = _configuration["VnPay:HashSecret"];
            var baseUrl = _configuration["VnPay:BaseUrl"];
            var returnUrl = _configuration["VnPay:ReturnUrl"];

            if (string.IsNullOrWhiteSpace(tmnCode) ||
                string.IsNullOrWhiteSpace(hashSecret) ||
                string.IsNullOrWhiteSpace(baseUrl) ||
                string.IsNullOrWhiteSpace(returnUrl))
            {
                return null;
            }

            return new VnPayConfig
            {
                TmnCode = tmnCode,
                HashSecret = hashSecret,
                BaseUrl = baseUrl,
                ReturnUrl = returnUrl
            };
        }

        private class VnPayConfig
        {
            public string TmnCode { get; set; } = null!;

            public string HashSecret { get; set; } = null!;

            public string BaseUrl { get; set; } = null!;

            public string ReturnUrl { get; set; } = null!;
        }
    }
}
