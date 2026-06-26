using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Payment;
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
    private readonly ILogger<SePayService> _logger;

    public SePayService(
        AdidasShoesStoreContext context,
        IOptions<SePaySettings> options,
        IOptions<PaymentSettings> paymentSettings,
        IEmailService emailService,
        ILogger<SePayService> logger)
    {
        _context = context;
        _settings = options.Value;
        _paymentSettings = paymentSettings.Value;
        _emailService = emailService;
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
        if (!VerifyWebhook(rawBody, authorization, signature, timestamp))
            return PaymentServiceResult<PaymentStatusDto?>.Fail("Invalid SePay webhook authentication", "Unauthorized");

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

        var content = $"{payload.Code} {payload.Content}".Trim();
        var order = await _context.Orders
            .Include(o => o.Payment)
            .Include(o => o.User)
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.Variant)
            .FirstOrDefaultAsync(o =>
                o.Payment != null &&
                o.Payment.PaymentMethod == "SEPAY" &&
                o.Payment.TransferContent != null &&
                content.Contains(o.Payment.TransferContent, StringComparison.OrdinalIgnoreCase));

        if (order?.Payment == null)
        {
            _logger.LogWarning(
                "SePay webhook transaction {TransactionId} did not match an order. Content: {Content}",
                providerTransactionId,
                content);
            return PaymentServiceResult<PaymentStatusDto?>.Ok(null);
        }

        if (order.Payment.Status == "Success" || order.Status == "Paid")
            return PaymentServiceResult<PaymentStatusDto?>.Ok(MapStatus(order));

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

    private string BuildTransferContent(string orderCode)
    {
        var prefix = _settings.PaymentContentPrefix.Trim().ToUpperInvariant();
        return $"{prefix}-{orderCode}".Replace(" ", string.Empty);
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
            if (string.IsNullOrWhiteSpace(signature) || string.IsNullOrWhiteSpace(timestamp))
                return false;
            if (!long.TryParse(timestamp, out var unixTimestamp))
                return false;

            var webhookTime = DateTimeOffset.FromUnixTimeSeconds(unixTimestamp);
            if (Math.Abs((DateTimeOffset.UtcNow - webhookTime).TotalMinutes) > 5)
                return false;

            var payload = $"{timestamp}.{rawBody}";
            var expectedBytes = HMACSHA256.HashData(
                Encoding.UTF8.GetBytes(_settings.WebhookSecret),
                Encoding.UTF8.GetBytes(payload));
            var expected = Convert.ToHexString(expectedBytes).ToLowerInvariant();
            var received = signature.StartsWith("sha256=", StringComparison.OrdinalIgnoreCase)
                ? signature[7..]
                : signature;

            return CryptographicOperations.FixedTimeEquals(
                Encoding.UTF8.GetBytes(expected),
                Encoding.UTF8.GetBytes(received.ToLowerInvariant()));
        }

        if (string.IsNullOrWhiteSpace(_settings.ApiKey))
            return false;

        var expectedAuthorization = $"Apikey {_settings.ApiKey}";
        return string.Equals(authorization, expectedAuthorization, StringComparison.Ordinal);
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
