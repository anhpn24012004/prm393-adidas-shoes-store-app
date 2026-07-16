namespace AdidasShoesStore.Api.DTOs.Ghn
{
    public class GhnApiResponseDto<T>
    {
        public bool Success { get; set; }

        public string? Message { get; set; }

        public T? Data { get; set; }

        public static GhnApiResponseDto<T> Ok(T data)
        {
            return new GhnApiResponseDto<T>
            {
                Success = true,
                Data = data
            };
        }

        public static GhnApiResponseDto<T> Fail(string message)
        {
            return new GhnApiResponseDto<T>
            {
                Success = false,
                Message = message
            };
        }
    }
}
