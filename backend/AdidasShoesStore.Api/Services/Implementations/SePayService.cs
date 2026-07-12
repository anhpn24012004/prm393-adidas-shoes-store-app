using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
using AdidasShoesStore.Api.Constants;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Services.Implementations;

public class SePayService : ISePayService
{
    private readonly AdidasShoesStoreContext _context;
    private readonly SePaySettings _settings;
    private readonly PaymentSettings _paymentSettings;
    private readonly IEmailService _emailService;
    private readonly INotificationService _notificationService;
    private readonly ILogger<SePayService> _logger;

    public SePayService(
        AdidasShoesStoreContext context,
        IOptions<SePaySettings> options,
        IOptions<PaymentSettings> paymentSettings,
        IEmailService emailService,
        INotificationService notificationService,
        ILogger<SePayService> logger)
    {
        _context = context;
        _settings = options.Value;
        _paymentSettings = paymentSettings.Value;
        _emailService = emailService;
        _notificationService = notificationService;
        _logger = logger;
    }

    public async Task<PaymentServiceResult<SePayPaymentResponseDto>> CreatePaymentAsync(
        int userId,
        CreateSePayPaymentDto dto)
    {
        var configError = GetConfigurationError();
        if (configError != null)
            return PaymentServiceResult<SePayPaymentResponseDto>.Fail(configError);

        var order = await _context.Orders
            .Include(o => o.Payment)
            .FirstOrDefaultAsync(o => o.OrderId == dto.OrderId && o.UserId == userId);

        if (order == null)
            return PaymentServiceResult<SePayPaymentResponseDto>.Fail("Order not found", "NotFound");
        if (order.FinalAmount <= 0)
            return PaymentServiceResult<SePayPaymentResponseDto>.Fail("Order total must be greater than zero");
        if (order.Status != "PendingPayment" || order.Payment == null)
            return PaymentServiceResult<SePayPaymentResponseDto>.Fail("Order is not awaiting payment");
        if (!string.Equals(order.Payment.PaymentMethod, "SEPAY", StringComparison.OrdinalIgnoreCase))
            return PaymentServiceResult<SePayPaymentResponseDto>.Fail("Payment method must be SEPAY");

        var transferContent = BuildTransferContent(order.OrderCode);
        order.Payment.PaymentProvider = "SEPAY";
        order.Payment.TransferContent = transferContent;
        order.Payment.Status = "Pending";
        await _context.SaveChangesAsync();

        var amount = ((long)Math.Ceiling(order.FinalAmount)).ToString(CultureInfo.InvariantCulture);
        var qrCodeUrl =
            $"https://qr.sepay.vn/img?acc={Uri.EscapeDataString(_settings.BankAccountNumber)}" +
            $"&bank={Uri.EscapeDataString(_settings.BankCode)}" +
            $"&amount={amount}&des={Uri.EscapeDataString(transferContent)}";

        return PaymentServiceResult<SePayPaymentResponseDto>.Ok(new SePayPaymentResponseDto
        {
            OrderId = order.OrderId,
            Amount = order.FinalAmount,
            BankCode = _settings.BankCode,
            BankAccountNumber = _settings.BankAccountNumber,
            AccountName = _settings.AccountName,
            TransferContent = transferContent,
            QrCodeUrl = qrCodeUrl,
            PaymentStatus = order.Payment.Status,
            ExpiresAt = GetPaymentExpiresAt(order)
        });
    }

    public async Task<PaymentServiceResult<PaymentStatusDto?>> ProcessWebhookAsync(
        string rawBody,
        string? authorization,
        string? signature,
        string? timestamp)
    {
        try
        {
            _logger.LogInformation("===== SEPAY WEBHOOK HIT =====");
            _logger.LogInformation("SePay rawBody: {RawBody}", rawBody);
            _logger.LogInformation(
                "SePay headers present. Authorization={HasAuthorization}, Signature={HasSignature}, Timestamp={HasTimestamp}",
                !string.IsNullOrWhiteSpace(authorization),
                !string.IsNullOrWhiteSpace(signature),
                !string.IsNullOrWhiteSpace(timestamp));

            if (!VerifyWebhook(rawBody, authorization, signature, timestamp))
            {
                LogWebhookAuthFailure(authorization);
                return PaymentServiceResult<PaymentStatusDto?>.Fail("Invalid SePay webhook authentication", "Unauthorized");
            }

            SePayWebhookDto? payload;
            try
            {
                payload = JsonSerializer.Deserialize<SePayWebhookDto>(
                    rawBody,
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
            }
            catch (JsonException)
            {
                return PaymentServiceResult<PaymentStatusDto?>.Fail("Invalid SePay webhook payload");
            }

            if (payload == null || payload.Id <= 0 || payload.TransferAmount <= 0)
                return PaymentServiceResult<PaymentStatusDto?>.Fail("Invalid SePay webhook payload");
            if (!string.Equals(payload.TransferType, "in", StringComparison.OrdinalIgnoreCase))
                return PaymentServiceResult<PaymentStatusDto?>.Ok(null);

            var providerTransactionId = payload.Id.ToString(CultureInfo.InvariantCulture);
            var existing = await _context.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.ProviderTransactionId == providerTransactionId);
            if (existing != null)
                return PaymentServiceResult<PaymentStatusDto?>.Ok(null);

            var content = $"{payload.Code} {payload.Content} {payload.Description}".Trim();
            var normalizedContent = NormalizeTransferContent(content);

            _logger.LogInformation("SePay normalized content: {NormalizedContent}", normalizedContent);

            var candidates = await _context.Orders
                .Include(o => o.Payment)
                .Include(o => o.User)
                .Include(o => o.OrderItems)
                .ThenInclude(i => i.Variant)
                .Where(o =>
                    o.Payment != null &&
                    o.Payment.PaymentMethod == "SEPAY" &&
                    o.Payment.TransferContent != null)
                .ToListAsync();

            var order = candidates.FirstOrDefault(o =>
            {
                var transferContent = o.Payment?.TransferContent;
                if (string.IsNullOrWhiteSpace(transferContent))
                    return false;

                var normalizedTransferContent = NormalizeTransferContent(transferContent);

                _logger.LogInformation(
                    "Checking SePay order match. OrderId={OrderId}, OrderCode={OrderCode}, TransferContent={TransferContent}, NormalizedTransferContent={NormalizedTransferContent}",
                    o.OrderId,
                    o.OrderCode,
                    transferContent,
                    normalizedTransferContent);

                return normalizedContent.Contains(normalizedTransferContent);
            });

            if (order?.Payment == null)
            {
                _logger.LogWarning(
                    "SePay webhook did not match any order. TransactionId={TransactionId}, Content={Content}, NormalizedContent={NormalizedContent}",
                    providerTransactionId,
                    content,
                    normalizedContent);

                return PaymentServiceResult<PaymentStatusDto?>.Ok(null);
            }

            if (order.Payment.Status == "Success" || order.Status == "Paid")
                return PaymentServiceResult<PaymentStatusDto?>.Ok(MapStatus(order));

            if (!CanAcceptPaymentSuccess(order, out var guardMessage))
            {
                _logger.LogWarning(
                    "Ignored late or invalid SePay success webhook for order {OrderCode}. OrderStatus={OrderStatus}, PaymentStatus={PaymentStatus}, Reason={Reason}",
                    order.OrderCode,
                    order.Status,
                    order.Payment.Status,
                    guardMessage);

                return PaymentServiceResult<PaymentStatusDto?>.Ok(MapStatus(order));
            }

            var expectedAmount = (long)Math.Ceiling(order.FinalAmount);
            if (payload.TransferAmount < expectedAmount)
            {
                _logger.LogWarning(
                    "SePay transaction {TransactionId} amount {PaidAmount} is below order {OrderCode} total {OrderTotal}",
                    providerTransactionId,
                    payload.TransferAmount,
                    order.OrderCode,
                    expectedAmount);
                return PaymentServiceResult<PaymentStatusDto?>.Ok(null);
            }

            order.Payment.Status = "Success";
            order.Payment.PaymentProvider = "SEPAY";
            order.Payment.ProviderTransactionId = providerTransactionId;
            order.Payment.TransactionCode = payload.ReferenceCode ?? providerTransactionId;
            order.Payment.PaidAmount = payload.TransferAmount;
            order.Payment.PaidAt = DateTime.UtcNow;
            order.Payment.RawWebhookData = rawBody;
            order.Status = "Paid";
            await ClearUserCartAsync(order.UserId);
            await _context.SaveChangesAsync();

            await NotificationDispatch.TryAsync(
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
                        relatedPaymentId: order.Payment.PaymentId);

                    await service.CreateForRoleAsync(
                        "Admin",
                        "Payment confirmed",
                        $"Order {order.OrderCode} has been paid successfully and is ready for processing.",
                        NotificationTypes.PaymentSuccess,
                        relatedOrderId: order.OrderId,
                        relatedPaymentId: order.Payment.PaymentId);
                });

            try
            {
                await _emailService.SendInvoiceEmailAsync(order);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Could not send invoice for SePay order {OrderCode}", order.OrderCode);
            }

            return PaymentServiceResult<PaymentStatusDto?>.Ok(MapStatus(order));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "SePay webhook processing failed");
            throw;
        }
    }

    private string BuildTransferContent(string orderCode)
    {
        var prefix = _settings.PaymentContentPrefix.Trim().ToUpperInvariant();
        return $"{prefix}-{orderCode}".Replace(" ", string.Empty);
    }

    private static string NormalizeTransferContent(string value)
    {
        return new string(value
            .Where(char.IsLetterOrDigit)
            .ToArray())
            .ToUpperInvariant();
    }

    private string? GetConfigurationError()
    {
        if (string.IsNullOrWhiteSpace(_settings.BankAccountNumber) ||
            string.IsNullOrWhiteSpace(_settings.BankCode) ||
            string.IsNullOrWhiteSpace(_settings.AccountName) ||
            string.IsNullOrWhiteSpace(_settings.PaymentContentPrefix))
            return "SePay configuration is missing or invalid";

        return null;
    }

    private bool VerifyWebhook(
        string rawBody,
        string? authorization,
        string? signature,
        string? timestamp)
    {
        if (!string.IsNullOrWhiteSpace(_settings.WebhookSecret))
        {
            if (string.IsNullOrWhiteSpace(signature))
                return false;

            var received = signature.StartsWith("sha256=", StringComparison.OrdinalIgnoreCase)
                ? signature[7..]
                : signature;

            received = received.Trim().ToLowerInvariant();

            bool CheckSignature(string payloadToSign)
            {
                var expectedBytes = HMACSHA256.HashData(
                    Encoding.UTF8.GetBytes(_settings.WebhookSecret),
                    Encoding.UTF8.GetBytes(payloadToSign));

                var expected = Convert.ToHexString(expectedBytes).ToLowerInvariant();

                if (expected.Length != received.Length)
                    return false;

                return CryptographicOperations.FixedTimeEquals(
                    Encoding.UTF8.GetBytes(expected),
                    Encoding.UTF8.GetBytes(received));
            }

            if (!string.IsNullOrWhiteSpace(timestamp))
            {
                if (long.TryParse(timestamp, out var unixTimestamp))
                {
                    var webhookTime = DateTimeOffset.FromUnixTimeSeconds(unixTimestamp);
                    if (Math.Abs((DateTimeOffset.UtcNow - webhookTime).TotalMinutes) <= 5)
                    {
                        if (CheckSignature($"{timestamp}.{rawBody}"))
                            return true;
                    }
                }
            }

            return CheckSignature(rawBody);
        }

        return VerifyApiKey(authorization);
    }

    private bool VerifyApiKey(string? authorization)
    {
        if (string.IsNullOrWhiteSpace(_settings.ApiKey))
            return false;

        var expectedApiKey = _settings.ApiKey.Trim();

        var auth = authorization?.Trim();
        if (string.IsNullOrWhiteSpace(auth))
            return false;

        if (string.Equals(auth, expectedApiKey, StringComparison.Ordinal))
            return true;

        var parts = auth.Split(
            new[] { ' ', '\t', '\r', '\n' },
            StringSplitOptions.RemoveEmptyEntries);

        if (parts.Length >= 2)
        {
            var scheme = parts[0].Trim();
            var providedKey = string.Join("", parts.Skip(1)).Trim();

            if (scheme.Equals("Apikey", StringComparison.OrdinalIgnoreCase) ||
                scheme.Equals("ApiKey", StringComparison.OrdinalIgnoreCase) ||
                scheme.Equals("Bearer", StringComparison.OrdinalIgnoreCase))
            {
                return string.Equals(providedKey, expectedApiKey, StringComparison.Ordinal);
            }
        }

        return false;
    }

    private void LogWebhookAuthFailure(string? authorization)
    {
        var auth = authorization?.Trim();
        var apiKey = _settings.ApiKey?.Trim();
        var webhookSecret = _settings.WebhookSecret?.Trim();

        _logger.LogWarning(
            "SePay webhook auth failed. AuthPresent={AuthPresent}, Scheme={Scheme}, AuthLength={AuthLength}, ApiKeyConfigured={ApiKeyConfigured}, ApiKeyLength={ApiKeyLength}, WebhookSecretConfigured={WebhookSecretConfigured}, WebhookSecretLength={WebhookSecretLength}",
            !string.IsNullOrWhiteSpace(auth),
            GetAuthorizationScheme(auth),
            auth?.Length ?? 0,
            !string.IsNullOrWhiteSpace(apiKey),
            apiKey?.Length ?? 0,
            !string.IsNullOrWhiteSpace(webhookSecret),
            webhookSecret?.Length ?? 0);
    }

    private static string GetAuthorizationScheme(string? authorization)
    {
        if (string.IsNullOrWhiteSpace(authorization))
            return "none";

        var parts = authorization.Split(
            new[] { ' ', '\t', '\r', '\n' },
            StringSplitOptions.RemoveEmptyEntries);

        return parts.Length >= 2 ? parts[0] : "raw";
    }

    private async Task ClearUserCartAsync(int userId)
    {
        var cart = await _context.Carts
            .Include(c => c.CartItems)
            .FirstOrDefaultAsync(c => c.UserId == userId);
        if (cart != null && cart.CartItems.Any())
            _context.CartItems.RemoveRange(cart.CartItems);
    }

    private DateTime? GetPaymentExpiresAt(Models.Order order)
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

    private bool CanAcceptPaymentSuccess(Models.Order order, out string message)
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

    private PaymentStatusDto MapStatus(Models.Order order)
    {
        return new PaymentStatusDto
        {
            OrderId = order.OrderId,
            OrderCode = order.OrderCode,
            PaymentId = order.Payment!.PaymentId,
            OrderStatus = order.Status,
            PaymentMethod = order.Payment.PaymentMethod,
            PaymentStatus = order.Payment.Status,
            Amount = order.Payment.Amount,
            TransactionCode = order.Payment.TransactionCode,
            PaidAt = order.Payment.PaidAt,
            ExpiresAt = GetPaymentExpiresAt(order)
        };
    }
}
