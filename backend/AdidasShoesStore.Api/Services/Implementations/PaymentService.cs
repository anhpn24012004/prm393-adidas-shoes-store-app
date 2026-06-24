using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Net.Http.Headers;
using System.Globalization;
using System.Text;
using System.Text.Json;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class PaymentService : IPaymentService
    {
        private readonly AdidasShoesStoreContext _context;
        private readonly IConfiguration _configuration;
        private readonly VnPayHelper _vnPayHelper;
        private readonly IEmailService _emailService;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(
            AdidasShoesStoreContext context,
            IConfiguration configuration,
            VnPayHelper vnPayHelper,
            IEmailService emailService,
            IHttpClientFactory httpClientFactory,
            ILogger<PaymentService> logger)
        {
            _context = context;
            _configuration = configuration;
            _vnPayHelper = vnPayHelper;
            _emailService = emailService;
            _httpClientFactory = httpClientFactory;
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
                ["vnp_ReturnUrl"] = GetReturnUrl(dto.ReturnUrl, config.ReturnUrl),
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
            queryParameters.TryGetValue("vnp_TransactionStatus", out var transactionStatus);
            queryParameters.TryGetValue("vnp_Amount", out var callbackAmountText);

            var order = await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(i => i.Variant)
                .FirstOrDefaultAsync(o => o.OrderCode == orderCode);

            if (order == null || order.Payment == null)
            {
                return new VnPayPaymentResponseDto
                {
                    Success = false,
                    Message = "Order or payment not found"
                };
            }

            if (!string.Equals(order.Payment.PaymentMethod, "VNPAY", StringComparison.OrdinalIgnoreCase))
            {
                return new VnPayPaymentResponseDto
                {
                    Success = false,
                    OrderCode = order.OrderCode,
                    Message = "Payment method must be VNPAY"
                };
            }

            if (order.Payment.Status == "Success")
            {
                return new VnPayPaymentResponseDto
                {
                    Success = true,
                    OrderCode = order.OrderCode,
                    Message = "Payment already processed"
                };
            }

            var expectedAmount = (long)(order.FinalAmount * 100m);
            var amountMatches = long.TryParse(callbackAmountText, out var callbackAmount) &&
                callbackAmount == expectedAmount;

            if (isValidHash &&
                responseCode == "00" &&
                transactionStatus == "00" &&
                amountMatches)
            {
                order.Payment.Status = "Success";
                order.Payment.TransactionCode = transactionNo;
                order.Payment.PaidAt = DateTime.UtcNow;
                order.Status = "Paid";
                await ClearUserCartAsync(order.UserId);

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
            await RestoreStockForUnpaidOrderAsync(order);
            await _context.SaveChangesAsync();

            return new VnPayPaymentResponseDto
            {
                Success = false,
                OrderCode = order.OrderCode,
                Message = isValidHash
                    ? amountMatches ? "Payment failed" : "Invalid payment amount"
                    : "Invalid payment signature"
            };
        }

        public async Task<PaymentServiceResult<PayPalPaymentResponseDto>> CreatePayPalPaymentUrlAsync(
            int userId,
            CreatePayPalPaymentDto dto)
        {
            var config = GetPayPalConfig();

            if (config == null)
            {
                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail("PayPal configuration is missing or invalid");
            }

            var order = await _context.Orders
                .Include(o => o.Payment)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == dto.OrderId &&
                    o.UserId == userId);

            if (order == null)
            {
                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Status != "PendingPayment")
            {
                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail(
                    "Only pending payment orders can be paid with PayPal"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "PAYPAL", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail(
                    "Payment method must be PAYPAL"
                );
            }

            try
            {
                var accessToken = await GetPayPalAccessTokenAsync(config);
                var returnUrl = AddOrderIdToUrl(GetReturnUrl(dto.ReturnUrl, config.ReturnUrl), order.OrderId);
                var cancelUrl = AddOrderIdToUrl(GetReturnUrl(dto.CancelUrl, config.CancelUrl), order.OrderId);
                var amount = ConvertVndToPayPalAmount(order.FinalAmount, config.VndToUsdRate);
                var client = _httpClientFactory.CreateClient();
                var request = new HttpRequestMessage(
                    HttpMethod.Post,
                    $"{config.BaseUrl}/v2/checkout/orders"
                );

                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                request.Content = JsonContent(new
                {
                    intent = "CAPTURE",
                    purchase_units = new[]
                    {
                        new
                        {
                            reference_id = order.OrderCode,
                            custom_id = order.OrderId.ToString(CultureInfo.InvariantCulture),
                            description = $"Adidas Shoes Store order {order.OrderCode}",
                            amount = new
                            {
                                currency_code = config.Currency,
                                value = amount
                            }
                        }
                    },
                    application_context = new
                    {
                        brand_name = "Adidas Shoes Store",
                        landing_page = "LOGIN",
                        user_action = "PAY_NOW",
                        return_url = returnUrl,
                        cancel_url = cancelUrl
                    }
                });

                var response = await client.SendAsync(request);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning(
                        "Could not create PayPal order for {OrderCode}. Status: {Status}. Response: {Response}",
                        order.OrderCode,
                        response.StatusCode,
                        content
                    );

                    return PaymentServiceResult<PayPalPaymentResponseDto>.Fail("Could not create PayPal payment");
                }

                using var document = JsonDocument.Parse(content);
                var root = document.RootElement;
                var paypalOrderId = root.GetProperty("id").GetString();
                var approvalUrl = GetPayPalApprovalUrl(root);

                if (string.IsNullOrWhiteSpace(paypalOrderId) ||
                    string.IsNullOrWhiteSpace(approvalUrl))
                {
                    return PaymentServiceResult<PayPalPaymentResponseDto>.Fail("PayPal approval URL was not returned");
                }

                order.Payment.TransactionCode = paypalOrderId;
                await _context.SaveChangesAsync();

                return PaymentServiceResult<PayPalPaymentResponseDto>.Ok(new PayPalPaymentResponseDto
                {
                    ApprovalUrl = approvalUrl,
                    PayPalOrderId = paypalOrderId
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not create PayPal payment for order {OrderCode}", order.OrderCode);

                return PaymentServiceResult<PayPalPaymentResponseDto>.Fail("Could not create PayPal payment");
            }
        }

        public async Task<PayPalPaymentResponseDto> ProcessPayPalReturnAsync(
            IReadOnlyDictionary<string, string> queryParameters)
        {
            var config = GetPayPalConfig();

            if (config == null)
            {
                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    Message = "PayPal configuration is missing or invalid"
                };
            }

            queryParameters.TryGetValue("token", out var paypalOrderId);
            var order = await FindPayPalOrderAsync(queryParameters, paypalOrderId);

            if (order == null || order.Payment == null)
            {
                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    Message = "Order or payment not found"
                };
            }

            if (!string.Equals(order.Payment.PaymentMethod, "PAYPAL", StringComparison.OrdinalIgnoreCase))
            {
                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    OrderCode = order.OrderCode,
                    Message = "Payment method must be PAYPAL"
                };
            }

            if (order.Payment.Status == "Success")
            {
                return new PayPalPaymentResponseDto
                {
                    Success = true,
                    OrderCode = order.OrderCode,
                    PayPalOrderId = paypalOrderId,
                    Message = "Payment already processed"
                };
            }

            if (!string.IsNullOrWhiteSpace(order.Payment.TransactionCode) &&
                !string.Equals(order.Payment.TransactionCode, paypalOrderId, StringComparison.Ordinal))
            {
                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    OrderCode = order.OrderCode,
                    PayPalOrderId = paypalOrderId,
                    Message = "PayPal order ID does not match this order"
                };
            }

            try
            {
                var accessToken = await GetPayPalAccessTokenAsync(config);
                var captureResult = await CapturePayPalOrderAsync(config, accessToken, paypalOrderId);
                var expectedAmount = ConvertVndToPayPalAmount(order.FinalAmount, config.VndToUsdRate);
                var amountMatches = string.Equals(captureResult.Amount, expectedAmount, StringComparison.Ordinal);

                if (captureResult.Success && amountMatches)
                {
                    order.Payment.Status = "Success";
                    order.Payment.TransactionCode = captureResult.TransactionCode ?? paypalOrderId;
                    order.Payment.PaidAt = DateTime.UtcNow;
                    order.Status = "Paid";
                    await ClearUserCartAsync(order.UserId);

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

                    return new PayPalPaymentResponseDto
                    {
                        Success = true,
                        OrderCode = order.OrderCode,
                        PayPalOrderId = paypalOrderId,
                        Message = message
                    };
                }

                order.Payment.Status = "Failed";
                await RestoreStockForUnpaidOrderAsync(order);
                await _context.SaveChangesAsync();

                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    OrderCode = order.OrderCode,
                    PayPalOrderId = paypalOrderId,
                    Message = amountMatches
                        ? captureResult.Message ?? "PayPal payment failed"
                        : "Invalid PayPal payment amount"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Could not capture PayPal payment for order {OrderCode}", order.OrderCode);

                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    OrderCode = order.OrderCode,
                    PayPalOrderId = paypalOrderId,
                    Message = "Could not capture PayPal payment"
                };
            }
        }

        public async Task<PayPalPaymentResponseDto> ProcessPayPalCancelAsync(
            IReadOnlyDictionary<string, string> queryParameters)
        {
            queryParameters.TryGetValue("token", out var paypalOrderId);
            var order = await FindPayPalOrderAsync(queryParameters, paypalOrderId);

            if (order?.Payment == null)
            {
                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    Message = "Order or payment not found"
                };
            }

            if (order.Payment.Status != "Success")
            {
                order.Payment.Status = "Failed";
                await RestoreStockForUnpaidOrderAsync(order);
            }

            await _context.SaveChangesAsync();

            return new PayPalPaymentResponseDto
            {
                Success = false,
                OrderCode = order.OrderCode,
                PayPalOrderId = paypalOrderId,
                Message = "PayPal payment was cancelled"
            };
        }

        public async Task<PaymentServiceResult<QrPaymentResponseDto>> CreateQrPaymentAsync(
            int userId,
            CreateQrPaymentDto dto)
        {
            var config = GetQrPaymentConfig();

            if (config == null)
            {
                return PaymentServiceResult<QrPaymentResponseDto>.Fail("QR payment configuration is missing or invalid");
            }

            var order = await _context.Orders
                .Include(o => o.Payment)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == dto.OrderId &&
                    o.UserId == userId);

            if (order == null)
            {
                return PaymentServiceResult<QrPaymentResponseDto>.Fail(
                    "Order not found",
                    "NotFound"
                );
            }

            if (order.Status != "PendingPayment")
            {
                return PaymentServiceResult<QrPaymentResponseDto>.Fail(
                    "Only pending payment orders can be paid with QR"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<QrPaymentResponseDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "QR", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<QrPaymentResponseDto>.Fail(
                    "Payment method must be QR"
                );
            }

            var transferContent = $"{config.TransferPrefix}{order.OrderCode}";
            var amount = ((long)Math.Round(order.FinalAmount, 0, MidpointRounding.AwayFromZero))
                .ToString(CultureInfo.InvariantCulture);
            var qrImageUrl =
                $"https://img.vietqr.io/image/{Uri.EscapeDataString(config.BankBin)}-{Uri.EscapeDataString(config.AccountNo)}-{Uri.EscapeDataString(config.Template)}.png" +
                $"?amount={amount}" +
                $"&addInfo={Uri.EscapeDataString(transferContent)}" +
                $"&accountName={Uri.EscapeDataString(config.AccountName)}";

            order.Payment.TransactionCode = transferContent;
            order.Payment.Status = "WaitingConfirm";
            await _context.SaveChangesAsync();

            return PaymentServiceResult<QrPaymentResponseDto>.Ok(new QrPaymentResponseDto
            {
                QrImageUrl = qrImageUrl,
                BankBin = config.BankBin,
                AccountNo = config.AccountNo,
                AccountName = config.AccountName,
                TransferContent = transferContent,
                Amount = order.FinalAmount
            });
        }

        public async Task<PaymentServiceResult<PaymentStatusDto>> ConfirmQrPaymentAsync(
            int userId,
            ConfirmQrPaymentDto dto)
        {
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
                    "Only pending payment orders can be confirmed"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "QR", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment method must be QR"
                );
            }

            if (order.Payment.Status == "Success")
            {
                return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
            }

            order.Payment.Status = "WaitingConfirm";
            await _context.SaveChangesAsync();

            return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
        }

        public async Task<PaymentServiceResult<PaymentStatusDto>> AdminConfirmQrPaymentAsync(
            ConfirmQrPaymentDto dto)
        {
            var order = await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId);

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
                    "Only pending payment orders can be confirmed"
                );
            }

            if (order.Payment == null)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment not found",
                    "NotFound"
                );
            }

            if (!string.Equals(order.Payment.PaymentMethod, "QR", StringComparison.OrdinalIgnoreCase))
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail(
                    "Payment method must be QR"
                );
            }

            if (order.Payment.Status == "Success")
            {
                return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
            }

            order.Payment.Status = "Success";
            order.Payment.TransactionCode ??= $"QR{DateTime.Now:yyyyMMddHHmmssfff}";
            order.Payment.PaidAt = DateTime.UtcNow;
            order.Status = "Paid";
            await ClearUserCartAsync(order.UserId);

            await _context.SaveChangesAsync();

            try
            {
                await _emailService.SendInvoiceEmailAsync(order);
            }
            catch
            {
                // Payment confirmation is already saved; email failure should not rollback it.
            }

            return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
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

            if (dto.Amount.HasValue && dto.Amount.Value != order.Payment.Amount)
            {
                return PaymentServiceResult<PaymentStatusDto>.Fail("Payment amount does not match order amount");
            }

            if (order.Payment.Status == "Success")
            {
                return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
            }

            // Demo-only simulated Visa payment. This validates card-like input but does not call a real gateway.
            order.Payment.Status = "Success";
            order.Payment.TransactionCode = $"VISA{DateTime.Now:yyyyMMddHHmmssfff}";
            order.Payment.PaidAt = DateTime.UtcNow;
            order.Status = "Paid";
            await ClearUserCartAsync(order.UserId);

            await _context.SaveChangesAsync();

            try
            {
                await _emailService.SendInvoiceEmailAsync(order);
            }
            catch
            {
                // Payment is already completed; email failure should not rollback the order.
            }

            return PaymentServiceResult<PaymentStatusDto>.Ok(MapPaymentStatus(order));
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

        private PayPalConfig? GetPayPalConfig()
        {
            var clientId = _configuration["PayPal:ClientId"];
            var clientSecret = _configuration["PayPal:ClientSecret"];
            var baseUrl = _configuration["PayPal:BaseUrl"];
            var returnUrl = _configuration["PayPal:ReturnUrl"];
            var cancelUrl = _configuration["PayPal:CancelUrl"];
            var currency = _configuration["PayPal:Currency"] ?? "USD";
            var rateText = _configuration["PayPal:VndToUsdRate"];

            if (string.IsNullOrWhiteSpace(clientId) ||
                string.IsNullOrWhiteSpace(clientSecret) ||
                string.IsNullOrWhiteSpace(baseUrl) ||
                string.IsNullOrWhiteSpace(returnUrl) ||
                string.IsNullOrWhiteSpace(cancelUrl) ||
                clientId.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                clientSecret.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                !decimal.TryParse(rateText, NumberStyles.Number, CultureInfo.InvariantCulture, out var vndToUsdRate) ||
                vndToUsdRate <= 0)
            {
                return null;
            }

            return new PayPalConfig
            {
                ClientId = clientId,
                ClientSecret = clientSecret,
                BaseUrl = baseUrl.TrimEnd('/'),
                ReturnUrl = returnUrl,
                CancelUrl = cancelUrl,
                Currency = currency,
                VndToUsdRate = vndToUsdRate
            };
        }

        private QrPaymentConfig? GetQrPaymentConfig()
        {
            var bankBin = _configuration["QrPayment:BankBin"];
            var accountNo = _configuration["QrPayment:AccountNo"];
            var accountName = _configuration["QrPayment:AccountName"];
            var template = _configuration["QrPayment:Template"] ?? "compact2";
            var transferPrefix = _configuration["QrPayment:TransferPrefix"] ?? "ADIDAS ";

            if (string.IsNullOrWhiteSpace(bankBin) ||
                string.IsNullOrWhiteSpace(accountNo) ||
                string.IsNullOrWhiteSpace(accountName) ||
                bankBin.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                accountNo.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            return new QrPaymentConfig
            {
                BankBin = bankBin.Trim(),
                AccountNo = accountNo.Trim(),
                AccountName = accountName.Trim(),
                Template = template.Trim(),
                TransferPrefix = transferPrefix.TrimEnd() + " "
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

        private static string GetReturnUrl(
            string? requestReturnUrl,
            string configuredReturnUrl)
        {
            if (Uri.TryCreate(requestReturnUrl, UriKind.Absolute, out var uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps))
            {
                return uri.ToString();
            }

            return configuredReturnUrl;
        }

        private async Task<string> GetPayPalAccessTokenAsync(PayPalConfig config)
        {
            var client = _httpClientFactory.CreateClient();
            var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"{config.BaseUrl}/v1/oauth2/token"
            );
            var credentials = Convert.ToBase64String(
                Encoding.ASCII.GetBytes($"{config.ClientId}:{config.ClientSecret}")
            );

            request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
            request.Content = new FormUrlEncodedContent(new Dictionary<string, string>
            {
                ["grant_type"] = "client_credentials"
            });

            var response = await client.SendAsync(request);
            var content = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new InvalidOperationException($"PayPal token request failed: {content}");
            }

            using var document = JsonDocument.Parse(content);

            return document.RootElement.GetProperty("access_token").GetString()
                ?? throw new InvalidOperationException("PayPal access token was not returned");
        }

        private async Task<PayPalCaptureResult> CapturePayPalOrderAsync(
            PayPalConfig config,
            string accessToken,
            string? paypalOrderId)
        {
            if (string.IsNullOrWhiteSpace(paypalOrderId))
            {
                return new PayPalCaptureResult
                {
                    Success = false,
                    Message = "PayPal order ID is missing"
                };
            }

            var client = _httpClientFactory.CreateClient();
            var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"{config.BaseUrl}/v2/checkout/orders/{paypalOrderId}/capture"
            );

            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            request.Content = JsonContent(new { });

            var response = await client.SendAsync(request);
            var content = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning(
                    "Could not capture PayPal order {PayPalOrderId}. Status: {Status}. Response: {Response}",
                    paypalOrderId,
                    response.StatusCode,
                    content
                );

                return new PayPalCaptureResult
                {
                    Success = false,
                    Message = "PayPal capture failed"
                };
            }

            using var document = JsonDocument.Parse(content);
            var root = document.RootElement;
            var status = root.TryGetProperty("status", out var statusElement)
                ? statusElement.GetString()
                : null;

            return new PayPalCaptureResult
            {
                Success = string.Equals(status, "COMPLETED", StringComparison.OrdinalIgnoreCase),
                TransactionCode = GetPayPalCaptureId(root) ?? paypalOrderId,
                Amount = GetPayPalCaptureAmount(root),
                Message = string.Equals(status, "COMPLETED", StringComparison.OrdinalIgnoreCase)
                    ? "Payment successful"
                    : $"PayPal payment status: {status ?? "Unknown"}"
            };
        }

        private async Task<Order?> FindPayPalOrderAsync(
            IReadOnlyDictionary<string, string> queryParameters,
            string? paypalOrderId)
        {
            Order? order = null;

            if (queryParameters.TryGetValue("orderId", out var orderIdText) &&
                int.TryParse(orderIdText, out var orderId))
            {
                order = await _context.Orders
                    .Include(o => o.Payment)
                    .Include(o => o.User)
                    .Include(o => o.OrderItems)
                        .ThenInclude(i => i.Variant)
                    .FirstOrDefaultAsync(o => o.OrderId == orderId);
            }

            if (order != null || string.IsNullOrWhiteSpace(paypalOrderId))
            {
                return order;
            }

            return await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                    .ThenInclude(i => i.Variant)
                .FirstOrDefaultAsync(o =>
                    o.Payment != null &&
                    o.Payment.TransactionCode == paypalOrderId);
        }

        private async Task ClearUserCartAsync(int userId)
        {
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart != null && cart.CartItems.Any())
            {
                _context.CartItems.RemoveRange(cart.CartItems);
            }
        }

        private Task RestoreStockForUnpaidOrderAsync(Order order)
        {
            if (order.Status != "PendingPayment")
            {
                return Task.CompletedTask;
            }

            foreach (var item in order.OrderItems)
            {
                if (item.Variant != null)
                {
                    item.Variant.StockQuantity = (item.Variant.StockQuantity ?? 0) + item.Quantity;
                }
            }

            order.Status = "Failed";

            return Task.CompletedTask;
        }

        private static PaymentStatusDto MapPaymentStatus(Order order)
        {
            return new PaymentStatusDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                OrderStatus = order.Status,
                PaymentMethod = order.Payment!.PaymentMethod,
                PaymentStatus = order.Payment.Status,
                Amount = order.Payment.Amount,
                TransactionCode = order.Payment.TransactionCode,
                PaidAt = order.Payment.PaidAt
            };
        }

        private static string AddOrderIdToUrl(
            string url,
            int orderId)
        {
            var separator = url.Contains('?', StringComparison.Ordinal) ? "&" : "?";

            return $"{url}{separator}orderId={orderId.ToString(CultureInfo.InvariantCulture)}";
        }

        private static string ConvertVndToPayPalAmount(
            decimal amountVnd,
            decimal vndToUsdRate)
        {
            var amount = Math.Round(amountVnd / vndToUsdRate, 2, MidpointRounding.AwayFromZero);

            if (amount < 0.01m)
            {
                amount = 0.01m;
            }

            return amount.ToString("0.00", CultureInfo.InvariantCulture);
        }

        private static string? GetPayPalApprovalUrl(JsonElement root)
        {
            if (!root.TryGetProperty("links", out var links) ||
                links.ValueKind != JsonValueKind.Array)
            {
                return null;
            }

            foreach (var link in links.EnumerateArray())
            {
                var rel = link.TryGetProperty("rel", out var relElement)
                    ? relElement.GetString()
                    : null;

                if (!string.Equals(rel, "approve", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                return link.TryGetProperty("href", out var hrefElement)
                    ? hrefElement.GetString()
                    : null;
            }

            return null;
        }

        private static string? GetPayPalCaptureId(JsonElement root)
        {
            if (!root.TryGetProperty("purchase_units", out var purchaseUnits) ||
                purchaseUnits.ValueKind != JsonValueKind.Array)
            {
                return null;
            }

            foreach (var purchaseUnit in purchaseUnits.EnumerateArray())
            {
                if (!purchaseUnit.TryGetProperty("payments", out var payments) ||
                    !payments.TryGetProperty("captures", out var captures) ||
                    captures.ValueKind != JsonValueKind.Array)
                {
                    continue;
                }

                foreach (var capture in captures.EnumerateArray())
                {
                    if (capture.TryGetProperty("id", out var idElement))
                    {
                        return idElement.GetString();
                    }
                }
            }

            return null;
        }

        private static string? GetPayPalCaptureAmount(JsonElement root)
        {
            if (!root.TryGetProperty("purchase_units", out var purchaseUnits) ||
                purchaseUnits.ValueKind != JsonValueKind.Array)
            {
                return null;
            }

            foreach (var purchaseUnit in purchaseUnits.EnumerateArray())
            {
                if (!purchaseUnit.TryGetProperty("payments", out var payments) ||
                    !payments.TryGetProperty("captures", out var captures) ||
                    captures.ValueKind != JsonValueKind.Array)
                {
                    continue;
                }

                foreach (var capture in captures.EnumerateArray())
                {
                    if (capture.TryGetProperty("amount", out var amount) &&
                        amount.TryGetProperty("value", out var value))
                    {
                        return value.GetString();
                    }
                }
            }

            return null;
        }

        private static StringContent JsonContent(object value)
        {
            return new StringContent(
                JsonSerializer.Serialize(value),
                Encoding.UTF8,
                "application/json"
            );
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

        private class PayPalConfig
        {
            public string ClientId { get; set; } = null!;

            public string ClientSecret { get; set; } = null!;

            public string BaseUrl { get; set; } = null!;

            public string ReturnUrl { get; set; } = null!;

            public string CancelUrl { get; set; } = null!;

            public string Currency { get; set; } = null!;

            public decimal VndToUsdRate { get; set; }
        }

        private class PayPalCaptureResult
        {
            public bool Success { get; set; }

            public string? TransactionCode { get; set; }

            public string? Amount { get; set; }

            public string? Message { get; set; }
        }

        private class QrPaymentConfig
        {
            public string BankBin { get; set; } = null!;

            public string AccountNo { get; set; } = null!;

            public string AccountName { get; set; } = null!;

            public string Template { get; set; } = null!;

            public string TransferPrefix { get; set; } = null!;
        }
    }
}
