using AdidasShoesStore.Api.DTOs.Order;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public class OrderServiceResult<T>
    {
        public bool Success { get; set; }

        public string? Error { get; set; }

        public string? ErrorType { get; set; }

        public T? Data { get; set; }

        public static OrderServiceResult<T> Ok(T data)
        {
            return new OrderServiceResult<T>
            {
                Success = true,
                Data = data
            };
        }

        public static OrderServiceResult<T> Fail(
            string error,
            string errorType = "BadRequest")
        {
            return new OrderServiceResult<T>
            {
                Success = false,
                Error = error,
                ErrorType = errorType
            };
        }
    }

    public interface IOrderService
    {
        Task<OrderServiceResult<OrderDetailDto>> CreateOrderAsync(
            int userId,
            CreateOrderDto dto
        );

        Task<List<OrderListDto>> GetMyOrdersAsync(int userId);

        Task<OrderDetailDto?> GetOrderDetailAsync(
            int userId,
            int orderId
        );

        Task<OrderServiceResult<OrderDetailDto>> CancelOrderAsync(
            int userId,
            int orderId
        );

        Task<OrderServiceResult<OrderDetailDto>> CompleteOrderAsync(
            int userId,
            int orderId
        );

        Task<List<AdminOrderListDto>> GetAdminOrdersAsync(
            string? status,
            DateTime? fromDate,
            DateTime? toDate,
            string? keyword
        );

        Task<AdminOrderDetailDto?> GetAdminOrderDetailAsync(int orderId);

        Task<OrderServiceResult<AdminOrderDetailDto>> UpdateOrderStatusAsync(
            int orderId,
            UpdateOrderStatusDto dto
        );

        Task<RevenueSummaryDto> GetRevenueSummaryAsync();
    }
}
