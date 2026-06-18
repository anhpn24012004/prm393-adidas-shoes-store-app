using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Globalization;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class PaymentService : IPaymentService
    {
        private readonly AdidasShoesStoreContext _context;
        private readonly IConfiguration _configuration;
        private readonly VnPayHelper _vnPayHelper;
        private readonly IEmailService _emailService;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(
            AdidasShoesStoreContext context,
            IConfiguration configuration,
            VnPayHelper vnPayHelper,
            IEmailService emailService,
            ILogger<PaymentService> logger)
        {
            _context = context;
            _configuration = configuration;
            _vnPayHelper = vnPayHelper;
            _emailService = emailService;
            _logger = logger;
        }

        public async Task<PaymentServiceResult<VnPayPaymentResponseDto>> CreateVnPayPaymentUrlAsync(
            int userId,
            CreateVnPayPaymentDto dto,
            string ipAddress)
        {
            var config = GetVnPayConfig();

            if (config == null)
            {
                return PaymentServiceResult<VnPayPaymentResponseDto>.Fail("VNPay configuration is missing or invalid");
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
                ["vnp_Amount"] = ((long)(order.FinalAmount * 100m)).ToString(CultureInfo.InvariantCulture),
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
                parameters,
                out var hashData
            );

            _logger.LogInformation(
                "Created VNPay payment URL for order {OrderCode}. HashData: {HashData}. PaymentUrl: {PaymentUrl}",
                order.OrderCode,
                hashData,
                paymentUrl
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
                    Message = "VNPay configuration is missing or invalid"
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

        public async Task<PaymentServiceResult<PaymentStatusDto>> PayWithVisaAsync(
            int userId,
            CreateVisaPaymentDto dto)
        {
            var validationError = ValidateVisaPayment(dto);

            if (validationError != null)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(validationError);
            }

            var order = await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == dto.OrderId &&
                    o.UserId == userId);

            if (order == null)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Status != "PendingPayment")
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Only pending payment orders can be paid with Visa"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "VISA", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment method must be VISA"
                );
            }

            order.Payment.Status = "Success";
            order.Payment.TransactionCode = $"VISA{DateTime.Now:yyyyMMddHHmmssfff}";
            order.Payment.PaidAt = DateTime.Now;
            order.Status = "Paid";

            await _context.SaveChangesAsync();

            try
            {
                await _emailService.SendInvoiceEmailAsync(order);
            }
            catch
            {
                // Payment is already completed; email failure should not rollback the order.
            }

            return PaymentServiceResult<PaymentStatusDto>.Ok(new PaymentStatusDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                OrderStatus = order.Status,
                PaymentMethod = order.Payment.PaymentMethod,
                PaymentStatus = order.Payment.Status,
                Amount = order.Payment.Amount,
                TransactionCode = order.Payment.TransactionCode,
                PaidAt = order.Payment.PaidAt
            });
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
                string.IsNullOrWhiteSpace(returnUrl) ||
                tmnCode.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                hashSecret.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
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

        private static string? ValidateVisaPayment(CreateVisaPaymentDto dto)
        {
            var cardNumber = DigitsOnly(dto.CardNumber);

            if (cardNumber.Length < 13 ||
                cardNumber.Length > 19 ||
                !cardNumber.StartsWith("4", StringComparison.Ordinal) ||
                !PassesLuhn(cardNumber))
            {
                return "Invalid Visa card number";
            }

            if (string.IsNullOrWhiteSpace(dto.CardHolderName))
            {
                return "Card holder name is required";
            }

            if (!int.TryParse(dto.ExpiryMonth, out var month) ||
                month < 1 ||
                month > 12)
            {
                return "Invalid expiry month";
            }

            if (!int.TryParse(dto.ExpiryYear, out var year))
            {
                return "Invalid expiry year";
            }

            if (year < 100)
            {
                year += 2000;
            }

            var lastValidDate = new DateTime(year, month, 1).AddMonths(1).AddDays(-1);

            if (lastValidDate < DateTime.Today)
            {
                return "Visa card is expired";
            }

            var cvv = DigitsOnly(dto.Cvv);

            if (cvv.Length < 3 || cvv.Length > 4)
            {
                return "Invalid CVV";
            }

            return null;
        }

        private static string DigitsOnly(string? value)
        {
            return string.Concat((value ?? string.Empty).Where(char.IsDigit));
        }

        private static bool PassesLuhn(string value)
        {
            var sum = 0;
            var doubleDigit = false;

            for (var index = value.Length - 1; index >= 0; index--)
            {
                var digit = value[index] - '0';

                if (doubleDigit)
                {
                    digit *= 2;

                    if (digit > 9)
                    {
                        digit -= 9;
                    }
                }

                sum += digit;
                doubleDigit = !doubleDigit;
            }

            return sum % 10 == 0;
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
