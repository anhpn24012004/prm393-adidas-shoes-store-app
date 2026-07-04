using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
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
        private readonly INotificationService _notificationService;
        private readonly IInventoryRealtimeService _inventoryRealtimeService;
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly ILogger<PaymentService> _logger;
        private readonly PaymentSettings _paymentSettings;

        public PaymentService(
            AdidasShoesStoreContext context,
            IConfiguration configuration,
            VnPayHelper vnPayHelper,
            IEmailService emailService,
            INotificationService notificationService,
            IInventoryRealtimeService inventoryRealtimeService,
            IHttpClientFactory httpClientFactory,
            ILogger<PaymentService> logger,
            IOptions<PaymentSettings> paymentSettings)
        {
            _context = context;
            _configuration = configuration;
            _vnPayHelper = vnPayHelper;
            _emailService = emailService;
            _notificationService = notificationService;
            _inventoryRealtimeService = inventoryRealtimeService;
            _httpClientFactory = httpClientFactory;
            _logger = logger;
            _paymentSettings = paymentSettings.Value;
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
                    OrderId = order.OrderId,
                    OrderCode = order.OrderCode,
                    Message = "Payment method must be VNPAY"
                };
            }

            if (order.Payment.Status == "Success")
            {
                return new VnPayPaymentResponseDto
                {
                    Success = true,
                    OrderId = order.OrderId,
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
                if (!CanAcceptPaymentSuccess(order, out var guardMessage))
                {
                    _logger.LogWarning(
                        "Ignored late or invalid VNPay success callback for order {OrderCode}. OrderStatus={OrderStatus}, PaymentStatus={PaymentStatus}, Reason={Reason}",
                        order.OrderCode,
                        order.Status,
                        order.Payment.Status,
                        guardMessage);

                    return new VnPayPaymentResponseDto
                    {
                        Success = false,
                        OrderId = order.OrderId,
                        OrderCode = order.OrderCode,
                        Message = guardMessage
                    };
                }

                order.Payment.Status = "Success";
                order.Payment.TransactionCode = transactionNo;
                order.Payment.PaidAt = DateTime.UtcNow;
                order.Status = "Paid";
                await ClearUserCartAsync(order.UserId);

                await _context.SaveChangesAsync();

                await NotifyPaymentSuccessAsync(order);

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
                    OrderId = order.OrderId,
                    OrderCode = order.OrderCode,
                    Message = message
                };
            }

            if (CanMarkPaymentFailed(order))
            {
                order.Payment.Status = "Failed";
                var restoredVariants = RestoreStockForUnpaidOrder(order);
                await _context.SaveChangesAsync();

                await _inventoryRealtimeService.NotifyStockChangedAsync(restoredVariants, "PaymentFailed");
                await NotifyPaymentFailedAsync(order, NotificationTypes.PaymentFailed);
            }

            return new VnPayPaymentResponseDto
            {
                Success = false,
                OrderId = order.OrderId,
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
                    OrderId = order.OrderId,
                    OrderCode = order.OrderCode,
                    Message = "Payment method must be PAYPAL"
                };
            }

            if (order.Payment.Status == "Success")
            {
                return new PayPalPaymentResponseDto
                {
                    Success = true,
                    OrderId = order.OrderId,
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
                    OrderId = order.OrderId,
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
                    if (!CanAcceptPaymentSuccess(order, out var guardMessage))
                    {
                        _logger.LogWarning(
                            "Ignored late or invalid PayPal success callback for order {OrderCode}. OrderStatus={OrderStatus}, PaymentStatus={PaymentStatus}, Reason={Reason}",
                            order.OrderCode,
                            order.Status,
                            order.Payment.Status,
                            guardMessage);

                        return new PayPalPaymentResponseDto
                        {
                            Success = false,
                            OrderId = order.OrderId,
                            OrderCode = order.OrderCode,
                            PayPalOrderId = paypalOrderId,
                            Message = guardMessage
                        };
                    }

                    order.Payment.Status = "Success";
                    order.Payment.TransactionCode = captureResult.TransactionCode ?? paypalOrderId;
                    order.Payment.PaidAt = DateTime.UtcNow;
                    order.Status = "Paid";
                    await ClearUserCartAsync(order.UserId);

                    await _context.SaveChangesAsync();

                    await NotifyPaymentSuccessAsync(order);

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
                        OrderId = order.OrderId,
                        OrderCode = order.OrderCode,
                        PayPalOrderId = paypalOrderId,
                        Message = message
                    };
                }

                if (CanMarkPaymentFailed(order))
                {
                    order.Payment.Status = "Failed";
                    var restoredVariants = RestoreStockForUnpaidOrder(order);
                    await _context.SaveChangesAsync();

                    await _inventoryRealtimeService.NotifyStockChangedAsync(restoredVariants, "PaymentFailed");
                    await NotifyPaymentFailedAsync(order, NotificationTypes.PaymentFailed);
                }

                return new PayPalPaymentResponseDto
                {
                    Success = false,
                    OrderId = order.OrderId,
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
                    OrderId = order.OrderId,
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

            if (CanMarkPaymentFailed(order))
            {
                order.Payment.Status = "Failed";
                var restoredVariants = RestoreStockForUnpaidOrder(order);
                await _context.SaveChangesAsync();
                await _inventoryRealtimeService.NotifyStockChangedAsync(restoredVariants, "PaymentFailed");
            }

            if (order.Payment.Status == "Failed")
            {
                await NotifyPaymentFailedAsync(order, NotificationTypes.PaymentFailed);
            }

            return new PayPalPaymentResponseDto
            {
                Success = false,
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                PayPalOrderId = paypalOrderId,
                Message = "PayPal payment was cancelled"
            };
        }

        public async Task<PaymentStatusDto?> GetPaymentStatusAsync(
            int userId,
            int orderId)
        {
            var order = await _context.Orders
                .AsNoTracking()
                .Include(o => o.Payment)
                .FirstOrDefaultAsync(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId);

            if (order?.Payment == null)
            {
                return null;
            }

            return MapPaymentStatus(order);
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

        private List<(int ProductId, int VariantId)> RestoreStockForUnpaidOrder(Order order)
        {
            var restoredVariants = new List<(int ProductId, int VariantId)>();

            if (order.Status != "PendingPayment")
            {
                return restoredVariants;
            }

            foreach (var item in order.OrderItems)
            {
                if (item.Variant != null)
                {
                    item.Variant.StockQuantity = (item.Variant.StockQuantity ?? 0) + item.Quantity;
                    restoredVariants.Add((item.Variant.ProductId, item.Variant.VariantId));
                }
            }

            order.Status = "Failed";

            return restoredVariants;
        }

        private bool CanAcceptPaymentSuccess(Order order, out string message)
        {
            if (order.Payment == null)
            {
                message = "Payment not found";
                return false;
            }

            if (!string.Equals(order.Status, "PendingPayment", StringComparison.OrdinalIgnoreCase) ||
                !string.Equals(order.Payment.Status, "Pending", StringComparison.OrdinalIgnoreCase))
            {
                message = "Order is no longer awaiting payment";
                return false;
            }

            var expiresAt = GetPaymentExpiresAt(order);
            if (expiresAt.HasValue && DateTime.UtcNow > expiresAt.Value)
            {
                message = "Payment callback arrived after the payment window expired";
                return false;
            }

            message = "Payment can be marked successful";
            return true;
        }

        private static bool CanMarkPaymentFailed(Order order)
        {
            return order.Payment != null &&
                string.Equals(order.Status, "PendingPayment", StringComparison.OrdinalIgnoreCase) &&
                string.Equals(order.Payment.Status, "Pending", StringComparison.OrdinalIgnoreCase);
        }

        private PaymentStatusDto MapPaymentStatus(Order order)
        {
            var payment = order.Payment!;
            var expiresAt = GetPaymentExpiresAt(order);
            var paymentStatus = payment.Status;
            string? message = null;

            if (string.Equals(payment.Status, "Pending", StringComparison.OrdinalIgnoreCase) &&
                string.Equals(order.Status, "PendingPayment", StringComparison.OrdinalIgnoreCase) &&
                expiresAt.HasValue &&
                DateTime.UtcNow > expiresAt.Value)
            {
                paymentStatus = "Expired";
                message = "Payment expired.";
            }
            else if (string.Equals(payment.Status, "Failed", StringComparison.OrdinalIgnoreCase))
            {
                message = order.Note != null &&
                    order.Note.Contains("Payment expired", StringComparison.OrdinalIgnoreCase)
                    ? "Payment expired."
                    : "Payment failed or expired.";
            }
            else if (string.Equals(order.Status, "Cancelled", StringComparison.OrdinalIgnoreCase))
            {
                message = "Payment cancelled.";
            }

            return new PaymentStatusDto
            {
                OrderId = order.OrderId,
                OrderCode = order.OrderCode,
                PaymentId = payment.PaymentId,
                OrderStatus = order.Status,
                PaymentMethod = payment.PaymentMethod,
                PaymentStatus = paymentStatus,
                Amount = payment.Amount,
                TransactionCode = payment.TransactionCode,
                PaidAt = payment.PaidAt,
                ExpiresAt = expiresAt,
                Message = message
            };
        }

        private DateTime? GetPaymentExpiresAt(Order order)
        {
            if (!string.Equals(order.Status, "PendingPayment", StringComparison.OrdinalIgnoreCase) ||
                order.Payment == null ||
                !string.Equals(order.Payment.Status, "Pending", StringComparison.OrdinalIgnoreCase) ||
                order.CreatedAt == null)
            {
                return null;
            }

            var expireMinutes = Math.Max(1, _paymentSettings.PendingPaymentExpireMinutes);
            return order.CreatedAt.Value.ToUniversalTime().AddMinutes(expireMinutes);
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

        private Task NotifyPaymentSuccessAsync(Order order)
        {
            return NotificationDispatch.TryAsync(
                _notificationService,
                _logger,
                async service =>
                {
                    await service.CreateForUserAsync(
                        order.UserId,
                        "Payment successful",
                        $"Your payment for order {order.OrderCode} has been confirmed.",
                        NotificationTypes.PaymentSuccess,
                        relatedOrderId: order.OrderId,
                        relatedPaymentId: order.Payment?.PaymentId);

                    await service.CreateForRoleAsync(
                        "Admin",
                        "Payment confirmed",
                        $"Order {order.OrderCode} has been paid successfully and is ready for processing.",
                        NotificationTypes.PaymentSuccess,
                        relatedOrderId: order.OrderId,
                        relatedPaymentId: order.Payment?.PaymentId);
                });
        }

        private Task NotifyPaymentFailedAsync(Order order, string type)
        {
            return NotificationDispatch.TryAsync(
                _notificationService,
                _logger,
                async service =>
                {
                    await service.CreateForUserAsync(
                        order.UserId,
                        type == NotificationTypes.PaymentExpired ? "Payment expired" : "Payment failed",
                        $"Payment for order {order.OrderCode} was not completed.",
                        type,
                        relatedOrderId: order.OrderId,
                        relatedPaymentId: order.Payment?.PaymentId);

                    await service.CreateForRoleAsync(
                        "Admin",
                        type == NotificationTypes.PaymentExpired ? "Payment expired" : "Payment failed",
                        $"Payment for order {order.OrderCode} was not completed.",
                        type,
                        relatedOrderId: order.OrderId,
                        relatedPaymentId: order.Payment?.PaymentId);
                });
        }

    }
}
