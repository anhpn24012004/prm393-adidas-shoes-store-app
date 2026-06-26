using AdidasShoesStore.Api.DTOs.Payment;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface ISePayService
{
    Task<PaymentServiceResult<SePayPaymentResponseDto>> CreatePaymentAsync(
        int userId,
        CreateSePayPaymentDto dto);

    Task<PaymentServiceResult<PaymentStatusDto?>> ProcessWebhookAsync(
        string rawBody,
        string? authorization,
        string? signature,
        string? timestamp);
}
