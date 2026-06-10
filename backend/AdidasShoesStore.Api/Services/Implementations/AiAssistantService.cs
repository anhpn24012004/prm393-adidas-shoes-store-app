using System.Text;
using System.Text.Json;
using AdidasShoesStore.Api.DTOs.AIRecommend;
using AdidasShoesStore.Api.Services.Interfaces;

namespace AdidasShoesStore.Api.Services.Implementations;

public class AiAssistantService : IAiAssistantService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;

    public AiAssistantService(
        HttpClient httpClient,
        IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
    }

    public async Task<AiShoeRecommendationResponseDto> RecommendShoesAsync(
        AiShoeRecommendationRequestDto request)
    {
        try
        {
            var apiKey = _configuration["Gemini:ApiKey"];
            var model = _configuration["Gemini:Model"] ?? "gemini-2.5-flash";

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                return new AiShoeRecommendationResponseDto
                {
                    RecommendedSize = "Chưa xác định",
                    Advice = "Chưa cấu hình Gemini API Key."
                };
            }

            var prompt =
                "Bạn là chuyên gia tư vấn giày Adidas.\n\n" +
                $"Giới tính: {request.Gender}\n" +
                $"Chiều dài bàn chân: {request.FootLengthCm} cm\n" +
                $"Độ rộng bàn chân: {request.FootWidth}\n" +
                $"Mục đích sử dụng: {request.Purpose}\n" +
                $"Ngân sách: {request.Budget} VND\n" +
                $"Màu sắc yêu thích: {request.FavoriteColor}\n\n" +
                "Hãy đề xuất size giày Adidas phù hợp và đưa ra lời khuyên ngắn gọn bằng tiếng Việt.\n\n" +
                "Chỉ trả về JSON hợp lệ theo đúng định dạng sau:\n" +
                "{\n" +
                "  \"recommendedSize\": \"EU42\",\n" +
                "  \"advice\": \"Lời khuyên bằng tiếng Việt\"\n" +
                "}";

            var requestBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new
                            {
                                text = prompt
                            }
                        }
                    }
                }
            };

            var url =
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

            var jsonBody = JsonSerializer.Serialize(requestBody);

            var response = await _httpClient.PostAsync(
                url,
                new StringContent(
                    jsonBody,
                    Encoding.UTF8,
                    "application/json")
            );

            var responseText = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                return new AiShoeRecommendationResponseDto
                {
                    RecommendedSize = SuggestSize(request.FootLengthCm),
                    Advice =
                        "Hệ thống AI đang quá tải hoặc tạm thời không khả dụng. " +
                        "Đây là kết quả tư vấn dự phòng dựa trên thông tin bàn chân của bạn."
                };
            }

            using var document = JsonDocument.Parse(responseText);

            var aiResponse = document.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            if (string.IsNullOrWhiteSpace(aiResponse))
            {
                return new AiShoeRecommendationResponseDto
                {
                    RecommendedSize = SuggestSize(request.FootLengthCm),
                    Advice = "AI không trả về dữ liệu."
                };
            }

            aiResponse = aiResponse
                .Replace("```json", "")
                .Replace("```", "")
                .Trim();

            var result = JsonSerializer.Deserialize<AiShoeRecommendationResponseDto>(
                aiResponse,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (result == null)
            {
                return new AiShoeRecommendationResponseDto
                {
                    RecommendedSize = SuggestSize(request.FootLengthCm),
                    Advice = "Không thể phân tích phản hồi từ AI."
                };
            }

            return result;
        }
        catch
        {
            return new AiShoeRecommendationResponseDto
            {
                RecommendedSize = SuggestSize(request.FootLengthCm),
                Advice =
                    "Hiện tại AI đang gặp sự cố. Đây là kết quả tư vấn dự phòng."
            };
        }
    }

    private string SuggestSize(double footLength)
    {
        if (footLength < 23) return "EU36";
        if (footLength < 24) return "EU38";
        if (footLength < 25) return "EU39";
        if (footLength < 26) return "EU40";
        if (footLength < 27) return "EU42";
        if (footLength < 28) return "EU43";

        return "EU44";
    }
}