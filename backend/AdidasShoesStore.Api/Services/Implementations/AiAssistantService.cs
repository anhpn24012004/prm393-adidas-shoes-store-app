using System.Globalization;
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
    private const int MaxRecommendations = 6;
    private const string ColorFallbackWarning =
        "Hiện chưa có sản phẩm đúng màu bạn chọn, hệ thống đang gợi ý lựa chọn gần nhất.";
    private const string BudgetFallbackWarning =
        "Hiện chưa có sản phẩm trong ngân sách của bạn, hệ thống đang gợi ý lựa chọn gần nhất.";

    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly AdidasShoesStoreContext _context;
    private readonly ILogger<AiAssistantService> _logger;

    public AiAssistantService(
        HttpClient httpClient,
        IConfiguration configuration,
        AdidasShoesStoreContext context,
        ILogger<AiAssistantService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _context = context;
        _logger = logger;
    }

    public object GetGeminiHealth()
    {
        var apiKey = _configuration["Gemini:ApiKey"];
        var model = GetGeminiModel();
        var configured = !string.IsNullOrWhiteSpace(apiKey);

        return new
        {
            geminiConfigured = configured,
            model,
            status = configured
                ? "Gemini is ready"
                : "Gemini API key is not configured; fallback advice will be used"
        };
    }

    public async Task<AiShoeRecommendationResponseDto> RecommendShoesAsync(
        AiShoeRecommendationRequestDto request)
    {
        var recommendedSize = SuggestSize(request.FootLengthCm);
        var fitWarning = BuildFitWarning(request.FootWidth, recommendedSize);
        var recommendationResult = await FindRecommendedProductsAsync(request, recommendedSize);
        var warnings = BuildWarnings(recommendationResult.ColorFallback, recommendationResult.BudgetFallback);

        var fallbackAdvice = BuildFallbackAdvice(
            request,
            recommendedSize,
            fitWarning,
            recommendationResult.Recommendations,
            warnings,
            recommendationResult.BudgetFallback);

        var aiAdvice = await TryGetAiAdviceAsync(
            request,
            recommendedSize,
            fitWarning,
            recommendationResult.Recommendations,
            warnings,
            recommendationResult.ColorFallback,
            recommendationResult.BudgetFallback);

        var advice = aiAdvice ?? fallbackAdvice;

        return new AiShoeRecommendationResponseDto
        {
            Success = true,
            IsAiGenerated = aiAdvice != null,
            ColorFallback = recommendationResult.ColorFallback,
            BudgetFallback = recommendationResult.BudgetFallback,
            RecommendedSize = recommendedSize,
            Summary = advice.Summary,
            SizeAdvice = advice.SizeAdvice,
            FitWarning = string.IsNullOrWhiteSpace(advice.FitWarning)
                ? null
                : advice.FitWarning,
            Warnings = warnings,
            BuyingTips = advice.BuyingTips,
            Recommendations = recommendationResult.Recommendations
        };
    }

    private async Task<RecommendationSelectionResult> FindRecommendedProductsAsync(
        AiShoeRecommendationRequestDto request,
        int recommendedSize)
    {
        var allCandidates = await _context.ProductVariants
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

        var sizeCandidates = allCandidates
            .Where(variant => IsSizeNear(variant.Size, recommendedSize))
            .ToList();

        var baseCandidates = sizeCandidates.Count > 0 ? sizeCandidates : allCandidates;
        var colorCandidates = ApplyColorFilter(baseCandidates, request.FavoriteColor);
        var budgetCandidates = ApplyBudgetFilter(colorCandidates.Candidates, request.Budget);

        var recommendations = budgetCandidates.Candidates
            .Select(variant => ScoreVariant(variant, request, recommendedSize))
            .Where(item => item.MatchScore > 0)
            .OrderByDescending(item => item.MatchScore)
            .ThenBy(item => item.Variant.Price)
            .GroupBy(item => item.Variant.ProductId)
            .Select(group => group.First())
            .Take(MaxRecommendations)
            .Select(ToRecommendedProduct)
            .ToList();

        return new RecommendationSelectionResult(
            recommendations,
            colorCandidates.IsFallback,
            budgetCandidates.IsFallback);
    }

    private static FilterResult ApplyColorFilter(
        List<ProductVariant> candidates,
        string favoriteColor)
    {
        var requestedColor = NormalizeColor(favoriteColor);
        if (string.IsNullOrWhiteSpace(requestedColor))
        {
            return new FilterResult(candidates, false);
        }

        var sameColor = candidates
            .Where(variant => NormalizeColor(variant.Color) == requestedColor)
            .ToList();

        if (sameColor.Count == 0)
        {
            return new FilterResult(candidates, true);
        }

        var sameColorWithImage = sameColor
            .Where(variant => HasImageForColor(variant, requestedColor))
            .ToList();

        return sameColorWithImage.Count > 0
            ? new FilterResult(sameColorWithImage, false)
            : new FilterResult(sameColor, false);
    }

    private static FilterResult ApplyBudgetFilter(
        List<ProductVariant> candidates,
        decimal budget)
    {
        if (budget <= 0)
        {
            return new FilterResult(candidates, false);
        }

        var inBudget = candidates
            .Where(variant => variant.Price <= budget)
            .ToList();

        return inBudget.Count > 0
            ? new FilterResult(inBudget, false)
            : new FilterResult(candidates, true);
    }

    private static ScoredVariant ScoreVariant(
        ProductVariant variant,
        AiShoeRecommendationRequestDto request,
        int recommendedSize)
    {
        var product = variant.Product;
        var score = 0;
        var tags = new List<string>();
        var requestedColor = NormalizeColor(request.FavoriteColor);
        var variantColor = NormalizeColor(variant.Color);
        var hasColorPreference = !string.IsNullOrWhiteSpace(requestedColor);
        var hasBudget = request.Budget > 0;
        var purpose = NormalizeText(request.Purpose);
        var gender = NormalizeText(request.Gender);
        var productGender = NormalizeText(product.Gender);
        var category = NormalizeText(product.Category?.CategoryName);
        var name = NormalizeText(product.ProductName);
        var description = NormalizeText(product.Description);
        var inStock = (variant.StockQuantity ?? 0) > 0;

        if (NormalizeSize(variant.Size) == recommendedSize)
        {
            score += 30;
            tags.Add("Đúng size");
        }

        if (inStock)
        {
            score += 20;
            tags.Add("Còn hàng");
        }

        if (hasColorPreference && variantColor == requestedColor)
        {
            score += 20;
            tags.Add("Màu đúng sở thích");
        }

        if (hasBudget && variant.Price <= request.Budget)
        {
            score += 20;
            tags.Add("Trong ngân sách");
        }

        if (MatchesPurpose(purpose, category, name, description))
        {
            score += 10;
            tags.Add(BuildPurposeTag(request.Purpose));
        }

        if (GenderMatches(gender, productGender))
        {
            score += 5;
            tags.Add("Phù hợp giới tính");
        }

        if (FootWidthMatches(request.FootWidth, name, description))
        {
            score += 5;
            tags.Add("Hợp độ rộng chân");
        }

        return new ScoredVariant(
            variant,
            Math.Clamp(score, 0, 100),
            tags.Distinct().ToList());
    }

    private static AiRecommendedProductDto ToRecommendedProduct(ScoredVariant item)
    {
        var variant = item.Variant;
        var imageUrl = ResolveVariantImageUrl(variant);
        var reason = BuildProductReason(variant, item.ReasonTags);

        return new AiRecommendedProductDto
        {
            ProductId = variant.ProductId,
            VariantId = variant.VariantId,
            ProductName = variant.Product.ProductName,
            CategoryName = variant.Product.Category?.CategoryName,
            MainImageUrl = imageUrl,
            ImageUrl = imageUrl,
            Size = variant.Size,
            Color = variant.Color,
            Price = variant.Price,
            StockQuantity = variant.StockQuantity ?? 0,
            MatchScore = item.MatchScore,
            Reason = reason,
            ReasonTags = item.ReasonTags
        };
    }

    private static string? ResolveVariantImageUrl(ProductVariant variant)
    {
        var color = NormalizeColor(variant.Color);

        if (!string.IsNullOrWhiteSpace(variant.ImageUrl) &&
            (string.IsNullOrWhiteSpace(color) || ImageUrlMatchesColor(variant.ImageUrl, color)))
        {
            return variant.ImageUrl;
        }

        var colorImage = string.IsNullOrWhiteSpace(color)
            ? null
            : variant.Product.ProductImages.FirstOrDefault(image =>
                !string.IsNullOrWhiteSpace(image.ImageUrl) &&
                ImageUrlMatchesColor(image.ImageUrl, color));

        var mainImage = variant.Product.ProductImages
            .OrderByDescending(image => image.IsMain == true)
            .ThenBy(image => image.ImageId)
            .FirstOrDefault();

        return colorImage?.ImageUrl ??
               mainImage?.ImageUrl ??
               variant.Product.ProductImages.FirstOrDefault()?.ImageUrl;
    }

    private static bool ImageUrlMatchesColor(string imageUrl, string color)
    {
        var normalizedImageUrl = NormalizeText(imageUrl);
        var tokens = normalizedImageUrl
            .Split(
                ['/', '\\', '-', '_', '.', ' ', '%'],
                StringSplitOptions.RemoveEmptyEntries);

        return color switch
        {
            "gray" => tokens.Contains("gray") || tokens.Contains("grey"),
            _ => tokens.Contains(color)
        };
    }

    private static bool HasImageForColor(ProductVariant variant, string color)
    {
        if (!string.IsNullOrWhiteSpace(variant.ImageUrl) &&
            ImageUrlMatchesColor(variant.ImageUrl, color))
        {
            return true;
        }

        return variant.Product.ProductImages.Any(image =>
            !string.IsNullOrWhiteSpace(image.ImageUrl) &&
            ImageUrlMatchesColor(image.ImageUrl, color));
    }

    private static string BuildProductReason(
        ProductVariant variant,
        List<string> reasonTags)
    {
        var strengths = reasonTags
            .Where(tag => tag is not "Phù hợp giới tính")
            .Take(4)
            .Select(tag => tag.ToLowerInvariant())
            .ToList();

        if (strengths.Count == 0)
        {
            return $"{variant.Product.ProductName} là lựa chọn gần nhất với tiêu chí hiện tại.";
        }

        var joined = strengths.Count == 1
            ? strengths[0]
            : string.Join(", ", strengths.Take(strengths.Count - 1)) + " và " + strengths[^1];

        return $"{variant.Product.ProductName} phù hợp vì {joined}.";
    }

    private async Task<AiGeneratedAdviceDto?> TryGetAiAdviceAsync(
        AiShoeRecommendationRequestDto request,
        int recommendedSize,
        string? fitWarning,
        List<AiRecommendedProductDto> products,
        List<string> warnings,
        bool colorFallback,
        bool budgetFallback)
    {
        var apiKey = _configuration["Gemini:ApiKey"];
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            return null;
        }

        try
        {
            var model = GetGeminiModel();
            var prompt = BuildGeminiPrompt(
                request,
                recommendedSize,
                fitWarning,
                products,
                warnings,
                colorFallback,
                budgetFallback);

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
                },
                generationConfig = new
                {
                    temperature = 0.25,
                    responseMimeType = "application/json"
                }
            };

            using var timeout = new CancellationTokenSource(TimeSpan.FromSeconds(12));
            using var response = await _httpClient.PostAsync(
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}",
                new StringContent(
                    JsonSerializer.Serialize(requestBody),
                    Encoding.UTF8,
                    "application/json"),
                timeout.Token);

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning(
                    "Gemini recommendation request failed with status {StatusCode}",
                    response.StatusCode);
                return null;
            }

            var responseText = await response.Content.ReadAsStringAsync(timeout.Token);
            var generatedJson = ExtractGeminiText(responseText);
            if (string.IsNullOrWhiteSpace(generatedJson))
            {
                return null;
            }

            generatedJson = StripMarkdownFence(generatedJson);
            var advice = JsonSerializer.Deserialize<AiGeneratedAdviceDto>(
                generatedJson,
                new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

            if (advice == null ||
                string.IsNullOrWhiteSpace(advice.Summary) ||
                string.IsNullOrWhiteSpace(advice.SizeAdvice))
            {
                return null;
            }

            advice.BuyingTips = advice.BuyingTips
                .Where(tip => !string.IsNullOrWhiteSpace(tip))
                .Take(4)
                .ToList();

            if (advice.BuyingTips.Count == 0)
            {
                advice.BuyingTips = BuildFallbackTips(request, products, budgetFallback);
            }

            return advice;
        }
        catch (Exception ex) when (
            ex is JsonException ||
            ex is HttpRequestException ||
            ex is TaskCanceledException ||
            ex is OperationCanceledException)
        {
            _logger.LogWarning(ex, "Gemini advice generation failed; fallback advice will be used.");
            return null;
        }
    }

    private static string BuildGeminiPrompt(
        AiShoeRecommendationRequestDto request,
        int recommendedSize,
        string? fitWarning,
        List<AiRecommendedProductDto> products,
        List<string> warnings,
        bool colorFallback,
        bool budgetFallback)
    {
        var productPayload = products.Select(product => new
        {
            productName = product.ProductName,
            price = product.Price,
            color = product.Color,
            size = product.Size,
            matchScore = product.MatchScore,
            reasonTags = product.ReasonTags
        });

        var context = new
        {
            user = new
            {
                request.Gender,
                request.FootLengthCm,
                request.FootWidth,
                request.Purpose,
                budget = request.Budget,
                favoriteColor = NormalizeColor(request.FavoriteColor)
            },
            recommendedSize,
            fitWarning,
            colorFallback,
            budgetFallback,
            warnings,
            recommendations = productPayload
        };

        return
            "Bạn là chuyên gia tư vấn giày Adidas. " +
            "Chỉ viết advice dựa trên recommendations do backend đã lọc, không thêm hoặc bịa sản phẩm. " +
            "Không được nói sản phẩm đúng màu nếu color không khớp favoriteColor. " +
            "Không được nói sản phẩm trong ngân sách nếu price > budget. " +
            "Nếu warnings có dữ liệu, hãy nhắc lại nhẹ nhàng trong summary hoặc buyingTips. " +
            "Trả về JSON thuần, không markdown, không dùng ```json. " +
            "Schema bắt buộc: {\"summary\":\"...\",\"sizeAdvice\":\"...\",\"fitWarning\":\"...\",\"buyingTips\":[\"...\",\"...\",\"...\"]}. " +
            JsonSerializer.Serialize(context);
    }

    private static string? ExtractGeminiText(string responseText)
    {
        using var document = JsonDocument.Parse(responseText);
        var root = document.RootElement;

        if (!root.TryGetProperty("candidates", out var candidates) ||
            candidates.GetArrayLength() == 0)
        {
            return null;
        }

        var candidate = candidates[0];
        if (!candidate.TryGetProperty("content", out var content) ||
            !content.TryGetProperty("parts", out var parts) ||
            parts.GetArrayLength() == 0)
        {
            return null;
        }

        return parts[0].TryGetProperty("text", out var text)
            ? text.GetString()
            : null;
    }

    private static string StripMarkdownFence(string value)
    {
        return value
            .Replace("```json", string.Empty, StringComparison.OrdinalIgnoreCase)
            .Replace("```", string.Empty, StringComparison.OrdinalIgnoreCase)
            .Trim();
    }

    private static AiGeneratedAdviceDto BuildFallbackAdvice(
        AiShoeRecommendationRequestDto request,
        int recommendedSize,
        string? fitWarning,
        List<AiRecommendedProductDto> products,
        List<string> warnings,
        bool budgetFallback)
    {
        var topProduct = products.FirstOrDefault();
        var warningPrefix = warnings.Count == 0
            ? string.Empty
            : string.Join(" ", warnings) + " ";

        string summary;
        if (topProduct == null)
        {
            summary = warningPrefix +
                      "Chưa tìm thấy sản phẩm phù hợp với tiêu chí hiện tại. Bạn có thể tăng ngân sách hoặc chọn màu Không quan trọng.";
        }
        else if (budgetFallback && request.Budget > 0)
        {
            summary = warningPrefix +
                      $"Lựa chọn gần nhất hiện là {topProduct.ProductName}, nhưng giá {FormatVnd(topProduct.Price)} đang vượt ngân sách {FormatVnd(request.Budget)}.";
        }
        else if (request.Budget > 0)
        {
            summary = warningPrefix +
                      $"Các sản phẩm bên dưới đều nằm trong ngân sách {FormatVnd(request.Budget)}. {topProduct.ProductName} là lựa chọn nổi bật với độ phù hợp {topProduct.MatchScore}%.";
        }
        else
        {
            summary = warningPrefix +
                      $"{topProduct.ProductName} là lựa chọn nổi bật nhất với độ phù hợp {topProduct.MatchScore}%.";
        }

        return new AiGeneratedAdviceDto
        {
            Summary = summary,
            SizeAdvice = $"Với chiều dài bàn chân {request.FootLengthCm:0.#} cm, bạn nên bắt đầu với size EU {recommendedSize}. Khi thử giày, phần mũi nên còn khoảng 0.5-1 cm để di chuyển thoải mái.",
            FitWarning = fitWarning,
            BuyingTips = BuildFallbackTips(request, products, budgetFallback)
        };
    }

    private static List<string> BuildFallbackTips(
        AiShoeRecommendationRequestDto request,
        List<AiRecommendedProductDto> products,
        bool budgetFallback)
    {
        var tips = new List<string>
        {
            "Ưu tiên đúng size và cảm giác chắc gót khi thử giày.",
            "Kiểm tra lại màu và size trên product card trước khi thêm vào giỏ.",
            "Thử giày vào cuối ngày vì bàn chân thường nở nhẹ sau khi di chuyển."
        };

        if (budgetFallback && request.Budget > 0)
        {
            tips.Insert(0, $"Hiện chưa tìm thấy sản phẩm trong ngân sách {FormatVnd(request.Budget)}, bạn có thể tăng ngân sách hoặc chọn tiêu chí linh hoạt hơn.");
        }
        else if (request.Budget > 0 && products.Count > 0)
        {
            tips.Insert(0, "Những sản phẩm bên dưới đều nằm trong ngân sách bạn đã chọn.");
        }

        return tips.Take(4).ToList();
    }

    private static List<string> BuildWarnings(bool colorFallback, bool budgetFallback)
    {
        var warnings = new List<string>();

        if (colorFallback)
        {
            warnings.Add(ColorFallbackWarning);
        }

        if (budgetFallback)
        {
            warnings.Add(BudgetFallbackWarning);
        }

        return warnings;
    }

    private static string? BuildFitWarning(string footWidth, int recommendedSize)
    {
        var width = NormalizeText(footWidth);

        if (width.Contains("rong") || width.Contains("wide"))
        {
            return $"Bàn chân rộng nên thử EU {recommendedSize} trước, sau đó cân nhắc tăng thêm 0.5-1 size nếu phần mũi hoặc hai bên thân giày bị ép.";
        }

        if (width.Contains("hep") || width.Contains("narrow"))
        {
            return "Bàn chân hẹp nên ưu tiên form ôm vừa, buộc dây chắc ở cổ chân và tránh tăng size nếu gót bị trượt.";
        }

        return null;
    }

    private static int SuggestSize(double footLength)
    {
        return footLength switch
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
            < 28.7 => 45,
            < 29.4 => 46,
            < 30.1 => 47,
            _ => 48
        };
    }

    private static bool IsSizeNear(string? size, int recommendedSize)
    {
        var normalizedSize = NormalizeSize(size);
        return normalizedSize > 0 && Math.Abs(normalizedSize - recommendedSize) <= 1;
    }

    private static bool MatchesPurpose(
        string purpose,
        string category,
        string name,
        string description)
    {
        if (string.IsNullOrWhiteSpace(purpose) || purpose.Contains("khong quan trong"))
        {
            return true;
        }

        if (purpose.Contains("chay") || purpose.Contains("running"))
        {
            return category.Contains("running") ||
                   category.Contains("chay") ||
                   name.Contains("boost") ||
                   name.Contains("adizero") ||
                   name.Contains("supernova") ||
                   name.Contains("runner");
        }

        if (purpose.Contains("bong") || purpose.Contains("football") || purpose.Contains("soccer"))
        {
            return category.Contains("football") ||
                   category.Contains("bong") ||
                   name.Contains("predator") ||
                   name.Contains("crazyfast") ||
                   name.Contains("copa");
        }

        if (purpose.Contains("gym") || purpose.Contains("tap") || purpose.Contains("training"))
        {
            return category.Contains("training") ||
                   description.Contains("training") ||
                   description.Contains("workout");
        }

        if (purpose.Contains("thoi trang") ||
            purpose.Contains("di hoc") ||
            purpose.Contains("lifestyle"))
        {
            return category.Contains("lifestyle") ||
                   category.Contains("originals") ||
                   name.Contains("samba") ||
                   name.Contains("gazelle") ||
                   name.Contains("superstar") ||
                   name.Contains("stan smith");
        }

        return category.Contains(purpose) ||
               name.Contains(purpose) ||
               description.Contains(purpose);
    }

    private static bool GenderMatches(string gender, string productGender)
    {
        if (string.IsNullOrWhiteSpace(gender) ||
            string.IsNullOrWhiteSpace(productGender) ||
            productGender.Contains("unisex"))
        {
            return true;
        }

        return productGender.Contains(gender) ||
               (gender.Contains("nam") && productGender.Contains("men")) ||
               (gender.Contains("nu") && productGender.Contains("women"));
    }

    private static bool FootWidthMatches(string footWidth, string name, string description)
    {
        var width = NormalizeText(footWidth);

        if (width.Contains("rong") || width.Contains("wide"))
        {
            return name.Contains("ultraboost") ||
                   name.Contains("supernova") ||
                   description.Contains("wide") ||
                   description.Contains("comfortable");
        }

        if (width.Contains("hep") || width.Contains("narrow"))
        {
            return name.Contains("adizero") ||
                   name.Contains("predator") ||
                   description.Contains("snug") ||
                   description.Contains("slim");
        }

        return true;
    }

    private static string BuildPurposeTag(string purpose)
    {
        return string.IsNullOrWhiteSpace(purpose)
            ? "Phù hợp nhu cầu"
            : $"Phù hợp {purpose.ToLowerInvariant()}";
    }

    private static int NormalizeSize(string? size)
    {
        if (string.IsNullOrWhiteSpace(size))
        {
            return 0;
        }

        var digits = new string(size.Where(char.IsDigit).ToArray());
        return int.TryParse(digits, out var value) ? value : 0;
    }

    private static string NormalizeColor(string? value)
    {
        var normalized = NormalizeText(value);

        if (string.IsNullOrWhiteSpace(normalized) ||
            normalized == "any" ||
            normalized == "none" ||
            normalized.Contains("khong quan trong"))
        {
            return string.Empty;
        }

        if (normalized.Contains("xanh la") || normalized.Contains("green"))
        {
            return "green";
        }

        if (normalized.Contains("do") || normalized.Contains("red"))
        {
            return "red";
        }

        if (normalized.Contains("den") || normalized.Contains("black"))
        {
            return "black";
        }

        if (normalized.Contains("trang") || normalized.Contains("white"))
        {
            return "white";
        }

        if (normalized.Contains("xam") ||
            normalized.Contains("gray") ||
            normalized.Contains("grey"))
        {
            return "gray";
        }

        if (normalized.Contains("xanh") || normalized.Contains("blue"))
        {
            return "blue";
        }

        return normalized;
    }

    private static string NormalizeText(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return string.Empty;
        }

        var normalized = value.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder(capacity: normalized.Length);

        foreach (var character in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark)
            {
                builder.Append(character);
            }
        }

        return builder
            .ToString()
            .Normalize(NormalizationForm.FormC)
            .Replace('đ', 'd');
    }

    private static string FormatVnd(decimal value)
    {
        return $"{value:0,0}đ".Replace(",", ".");
    }

    private string GetGeminiModel()
    {
        return _configuration["Gemini:Model"] ?? "gemini-2.5-flash";
    }

    private sealed record FilterResult(
        List<ProductVariant> Candidates,
        bool IsFallback);

    private sealed record RecommendationSelectionResult(
        List<AiRecommendedProductDto> Recommendations,
        bool ColorFallback,
        bool BudgetFallback);

    private sealed record ScoredVariant(
        ProductVariant Variant,
        int MatchScore,
        List<string> ReasonTags);
}
