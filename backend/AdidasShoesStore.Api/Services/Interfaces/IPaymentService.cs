using AdidasShoesStore.Api.DTOs.Payment;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public class PaymentServiceResult<T>
    {
        public bool Success { get; set; }

        public string? Error { get; set; }

        public string? ErrorType { get; set; }

        public T? Data { get; set; }

        public static PaymentServiceResult<T> Ok(T data)
        {
            return new PaymentServiceResult<T>
            {
                Success = true,
                Data = data
            };
        }

        public static PaymentServiceResult<T> Fail(
            string error,
            string errorType = "BadRequest")
        {
            return new PaymentServiceResult<T>
            {
                Success = false,
                Error = error,
                ErrorType = errorType
            };
        }
    }

    public interface IPaymentService
    {
        Task<PaymentServiceResult<VnPayPaymentResponseDto>> CreateVnPayPaymentUrlAsync(
            int userId,
            CreateVnPayPaymentDto dto,
            string ipAddress
        );

        Task<VnPayPaymentResponseDto> ProcessVnPayReturnAsync(
            IReadOnlyDictionary<string, string> queryParameters
        );

        Task<PaymentServiceResult<PaymentStatusDto>> PayWithVisaAsync(
            int userId,
            CreateVisaPaymentDto dto
        );

        Task<PaymentStatusDto?> GetPaymentStatusAsync(
            int userId,
            int orderId
        );
    }
}
