using System.Text;
using System.Text.Json;
using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.AIRecommend;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class AiAssistantService : IAiAssistantService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly AdidasShoesStoreContext _context;

    public AiAssistantService(
        HttpClient httpClient,
        IConfiguration configuration,
        AdidasShoesStoreContext context)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _context = context;
    }

    public async Task<AiShoeRecommendationResponseDto> RecommendShoesAsync(
        AiShoeRecommendationRequestDto request)
    {
        var recommendedSize = SuggestSize(request.FootLengthCm, request.FootWidth);
        var products = await FindRecommendedProductsAsync(request, recommendedSize);
        var fallbackAdvice = BuildFallbackAdvice(request, recommendedSize, products);
        var aiAdvice = await TryGetAiAdviceAsync(request, recommendedSize, products);

        return new AiShoeRecommendationResponseDto
        {
            RecommendedSize = recommendedSize,
            Advice = string.IsNullOrWhiteSpace(aiAdvice) ? fallbackAdvice : aiAdvice,
            RecommendedProducts = products
        };
    }

    private async Task<List<AiRecommendedProductDto>> FindRecommendedProductsAsync(
        AiShoeRecommendationRequestDto request,
        string recommendedSize)
    {
        var numericSize = recommendedSize.Replace("EU", "", StringComparison.OrdinalIgnoreCase);
        var favoriteColor = Normalize(request.FavoriteColor);
        var purpose = Normalize(request.Purpose);
        var gender = Normalize(request.Gender);

        var candidates = await _context.ProductVariants
            .AsNoTracking()
            .Include(variant => variant.Product)
                .ThenInclude(product => product.Category)
            .Include(variant => variant.Product)
                .ThenInclude(product => product.ProductImages)
            .Where(variant =>
                variant.IsActive == true &&
                variant.Product.IsActive == true &&
                variant.StockQuantity > 0 &&
                variant.Price <= request.Budget)
            .ToListAsync();

        if (candidates.Count == 0)
        {
            candidates = await _context.ProductVariants
                .AsNoTracking()
                .Include(variant => variant.Product)
                    .ThenInclude(product => product.Category)
                .Include(variant => variant.Product)
                    .ThenInclude(product => product.ProductImages)
                .Where(variant =>
                    variant.IsActive == true &&
                    variant.Product.IsActive == true &&
                    variant.StockQuantity > 0)
                .ToListAsync();
        }

        return candidates
            .Select(variant => new
            {
                Variant = variant,
                Score = ScoreVariant(
                    variant,
                    numericSize,
                    favoriteColor,
                    purpose,
                    gender,
                    request.Budget)
            })
            .OrderByDescending(item => item.Score)
            .ThenBy(item => item.Variant.Price)
            .GroupBy(item => item.Variant.ProductId)
            .Select(group => group.First())
            .Take(6)
            .Select(item => ToRecommendedProduct(
                item.Variant,
                item.Score,
                numericSize,
                favoriteColor,
                purpose,
                request.Budget))
            .ToList();
    }

    private static int ScoreVariant(
        ProductVariant variant,
        string numericSize,
        string favoriteColor,
        string purpose,
        string gender,
        decimal budget)
    {
        var product = variant.Product;
        var category = Normalize(product.Category.CategoryName);
        var name = Normalize(product.ProductName);
        var description = Normalize(product.Description);
        var color = Normalize(variant.Color);
        var productGender = Normalize(product.Gender);

        var score = 0;

        if (variant.Size == numericSize) score += 45;
        if (!string.IsNullOrWhiteSpace(favoriteColor) && color.Contains(favoriteColor)) score += 25;
        if (MatchesPurpose(purpose, category, name, description)) score += 35;
        if (string.IsNullOrWhiteSpace(productGender) ||
            string.IsNullOrWhiteSpace(gender) ||
            productGender.Contains("unisex") ||
            productGender.Contains(gender))
        {
            score += 10;
        }

        if (variant.Price <= budget) score += 20;
        if (variant.Price <= budget * 0.85m) score += 8;
        if ((variant.StockQuantity ?? 0) >= 5) score += 5;

        return score;
    }

    private static AiRecommendedProductDto ToRecommendedProduct(
        ProductVariant variant,
        int score,
        string numericSize,
        string favoriteColor,
        string purpose,
        decimal budget)
    {
        var mainImage = variant.Product.ProductImages
            .OrderByDescending(image => image.IsMain == true)
            .ThenBy(image => image.ImageId)
            .FirstOrDefault();

        return new AiRecommendedProductDto
        {
            ProductId = variant.ProductId,
            VariantId = variant.VariantId,
            ProductName = variant.Product.ProductName,
            CategoryName = variant.Product.Category.CategoryName,
            MainImageUrl = mainImage?.ImageUrl,
            Size = variant.Size,
            Color = variant.Color,
            Price = variant.Price,
            StockQuantity = variant.StockQuantity ?? 0,
            Reason = BuildProductReason(variant, score, numericSize, favoriteColor, purpose, budget)
        };
    }

    private static string BuildProductReason(
        ProductVariant variant,
        int score,
        string numericSize,
        string favoriteColor,
        string purpose,
        decimal budget)
    {
        var reasons = new List<string>();
        var product = variant.Product;
        var category = Normalize(product.Category.CategoryName);
        var name = Normalize(product.ProductName);
        var description = Normalize(product.Description);
        var color = Normalize(variant.Color);

        if (variant.Size == numericSize)
        {
            reasons.Add($"có sẵn size EU{variant.Size}");
        }

        if (!string.IsNullOrWhiteSpace(favoriteColor) && color.Contains(favoriteColor))
        {
            reasons.Add($"đúng màu {favoriteColor}");
        }

        if (MatchesPurpose(purpose, category, name, description))
        {
            reasons.Add($"phù hợp mục đích {purpose}");
        }

        if (variant.Price <= budget)
        {
            reasons.Add("nằm trong ngân sách");
        }

        if (reasons.Count == 0)
        {
            reasons.Add("là lựa chọn gần nhất với yêu cầu của bạn");
        }

        return string.Join(", ", reasons) + ".";
    }

    private async Task<string?> TryGetAiAdviceAsync(
        AiShoeRecommendationRequestDto request,
        string recommendedSize,
        List<AiRecommendedProductDto> products)
    {
        try
        {
            var apiKey = _configuration["Gemini:ApiKey"];
            var model = _configuration["Gemini:Model"] ?? "gemini-2.5-flash";

            if (string.IsNullOrWhiteSpace(apiKey))
            {
                return null;
            }

            var productText = products.Count == 0
                ? "Không có sản phẩm nào thỏa mãn hoàn toàn trong kho."
                : string.Join(
                    "\n",
                    products.Select(product =>
                        $"- {product.ProductName}: EU{product.Size}, màu {product.Color}, {product.Price:0} VND, {product.Reason}"));

            var prompt =
                "Bạn là chuyên gia tư vấn giày Adidas. " +
                "Hãy viết lời khuyên ngắn gọn bằng tiếng Việt dựa trên size đã tính và danh sách sản phẩm thật trong kho.\n\n" +
                $"Giới tính: {request.Gender}\n" +
                $"Chiều dài bàn chân: {request.FootLengthCm} cm\n" +
                $"Độ rộng bàn chân: {request.FootWidth}\n" +
                $"Mục đích sử dụng: {request.Purpose}\n" +
                $"Ngân sách: {request.Budget:0} VND\n" +
                $"Màu sắc yêu thích: {request.FavoriteColor}\n" +
                $"Size đề xuất: {recommendedSize}\n\n" +
                $"Sản phẩm phù hợp:\n{productText}\n\n" +
                "Chỉ trả về JSON hợp lệ theo định dạng:\n" +
                "{ \"advice\": \"Lời khuyên bằng tiếng Việt\" }";

            var requestBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = prompt }
                        }
                    }
                }
            };

            var url =
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

            var response = await _httpClient.PostAsync(
                url,
                new StringContent(
                    JsonSerializer.Serialize(requestBody),
                    Encoding.UTF8,
                    "application/json"));

            if (!response.IsSuccessStatusCode)
            {
                return null;
            }

            var responseText = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(responseText);

            var aiResponse = document.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            if (string.IsNullOrWhiteSpace(aiResponse))
            {
                return null;
            }

            aiResponse = aiResponse
                .Replace("```json", "")
                .Replace("```", "")
                .Trim();

            using var adviceDocument = JsonDocument.Parse(aiResponse);
            return adviceDocument.RootElement.TryGetProperty("advice", out var advice)
                ? advice.GetString()
                : null;
        }
        catch
        {
            return null;
        }
    }

    private static string BuildFallbackAdvice(
        AiShoeRecommendationRequestDto request,
        string recommendedSize,
        List<AiRecommendedProductDto> products)
    {
        if (products.Count == 0)
        {
            return $"Với bàn chân dài {request.FootLengthCm:0.#} cm, bạn nên thử {recommendedSize}. " +
                   "Hiện chưa có sản phẩm còn hàng phù hợp trong ngân sách, bạn có thể tăng ngân sách hoặc đổi màu yêu thích.";
        }

        var topProduct = products[0];
        return $"Với bàn chân dài {request.FootLengthCm:0.#} cm và độ rộng {request.FootWidth.ToLower()}, " +
               $"bạn nên thử {recommendedSize}. Gợi ý tốt nhất là {topProduct.ProductName} vì {topProduct.Reason}";
    }

    private static string SuggestSize(double footLength, string footWidth)
    {
        var size = footLength switch
        {
            < 22.5 => 36,
            < 23.0 => 37,
            < 23.8 => 38,
            < 24.5 => 39,
            < 25.2 => 40,
            < 25.9 => 41,
            < 26.6 => 42,
            < 27.3 => 43,
            < 28.0 => 44,
            _ => 45
        };

        if (Normalize(footWidth).Contains("rộng") && size < 45)
        {
            size += 1;
        }

        return $"EU{size}";
    }

    private static bool MatchesPurpose(
        string purpose,
        string category,
        string name,
        string description)
    {
        if (string.IsNullOrWhiteSpace(purpose))
        {
            return true;
        }

        if (purpose.Contains("chạy") || purpose.Contains("running"))
        {
            return category.Contains("running") ||
                   category.Contains("chạy") ||
                   name.Contains("boost") ||
                   name.Contains("adizero") ||
                   name.Contains("supernova");
        }

        if (purpose.Contains("bóng") || purpose.Contains("football") || purpose.Contains("soccer"))
        {
            return category.Contains("football") ||
                   category.Contains("bóng") ||
                   name.Contains("predator") ||
                   name.Contains("x crazyfast") ||
                   name.Contains("copa");
        }

        if (purpose.Contains("gym") || purpose.Contains("tập"))
        {
            return category.Contains("training") ||
                   category.Contains("lifestyle") ||
                   category.Contains("running") ||
                   description.Contains("training");
        }

        if (purpose.Contains("thời trang") || purpose.Contains("đi học") || purpose.Contains("lifestyle"))
        {
            return category.Contains("lifestyle") ||
                   category.Contains("originals") ||
                   name.Contains("samba") ||
                   name.Contains("gazelle") ||
                   name.Contains("superstar");
        }

        return category.Contains(purpose) ||
               name.Contains(purpose) ||
               description.Contains(purpose);
    }

    private static string Normalize(string? value)
    {
        return (value ?? string.Empty).Trim().ToLowerInvariant();
    }
}
