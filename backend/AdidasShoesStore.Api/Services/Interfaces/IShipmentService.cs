using AdidasShoesStore.Api.DTOs.Shipments;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public class ShipmentServiceResult<T>
    {
        public bool Success { get; set; }

        public string? Error { get; set; }

        public string? ErrorType { get; set; }

        public T? Data { get; set; }

        public static ShipmentServiceResult<T> Ok(T data)
        {
            return new ShipmentServiceResult<T>
            {
                Success = true,
                Data = data
            };
        }

        public static ShipmentServiceResult<T> Fail(
            string error,
            string errorType = "BadRequest")
        {
            return new ShipmentServiceResult<T>
            {
                Success = false,
                Error = error,
                ErrorType = errorType
            };
        }
    }

    public interface IShipmentService
    {
        Task<ShipmentDetailDto?> GetUserShipmentAsync(
            int userId,
            int orderId
        );

        Task<ShipmentTrackingDto?> GetUserTrackingAsync(
            int userId,
            int orderId
        );

        Task<List<AdminShipmentListDto>> GetAdminShipmentsAsync();

        Task<AdminShipmentDetailDto?> GetAdminShipmentAsync(int shipmentId);

        Task<ShipmentServiceResult<AdminShipmentDetailDto>> CreateShipmentAsync(
            CreateShipmentDto dto
        );

        Task<ShipmentServiceResult<AdminShipmentDetailDto>> UpdateShipmentStatusAsync(
            int shipmentId,
            UpdateShipmentStatusDto dto
        );

        Task<ShipmentServiceResult<AdminShipmentDetailDto>> UpdateTrackingInfoAsync(
            int shipmentId,
            UpdateTrackingInfoDto dto
        );

        Task<ShipmentServiceResult<AdminShipmentDetailDto>> SyncGhnStatusAsync(
            int shipmentId
        );
    }
}
