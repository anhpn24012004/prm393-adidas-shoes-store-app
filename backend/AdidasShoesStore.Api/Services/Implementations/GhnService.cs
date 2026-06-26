using System.Globalization;
using System.Text;
using System.Text.Json;
using AdidasShoesStore.Api.DTOs.Ghn;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.Extensions.Options;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class GhnService : IGhnService
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly GhnSettings _settings;
        private readonly ILogger<GhnService> _logger;

        public GhnService(
            IHttpClientFactory httpClientFactory,
            IOptions<GhnSettings> options,
            ILogger<GhnService> logger)
        {
            _httpClientFactory = httpClientFactory;
            _settings = options.Value;
            _logger = logger;
        }

        public async Task<GhnApiResponseDto<List<GhnProvinceDto>>> GetProvincesAsync()
        {
            var response = await SendAsync(HttpMethod.Get, "/master-data/province", null, false);

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<List<GhnProvinceDto>>.Fail(response.Message);
            }

            var items = DataArray(response.Root.Value)
                .Select(e => new GhnProvinceDto
                {
                    ProvinceId = GetInt(e, "ProvinceID"),
                    ProvinceName = GetString(e, "ProvinceName") ?? string.Empty
                })
                .Where(p => p.ProvinceId > 0 && !string.IsNullOrWhiteSpace(p.ProvinceName))
                .ToList();

            return GhnApiResponseDto<List<GhnProvinceDto>>.Ok(items);
        }

        public async Task<GhnApiResponseDto<List<GhnDistrictDto>>> GetDistrictsAsync(int provinceId)
        {
            if (provinceId <= 0)
            {
                return GhnApiResponseDto<List<GhnDistrictDto>>.Fail("Invalid province");
            }

            var response = await SendAsync(
                HttpMethod.Post,
                "/master-data/district",
                new { province_id = provinceId },
                false
            );

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<List<GhnDistrictDto>>.Fail(response.Message);
            }

            var items = DataArray(response.Root.Value)
                .Select(e => new GhnDistrictDto
                {
                    DistrictId = GetInt(e, "DistrictID"),
                    ProvinceId = GetInt(e, "ProvinceID"),
                    DistrictName = GetString(e, "DistrictName") ?? string.Empty
                })
                .Where(d => d.DistrictId > 0 && !string.IsNullOrWhiteSpace(d.DistrictName))
                .ToList();

            return GhnApiResponseDto<List<GhnDistrictDto>>.Ok(items);
        }

        public async Task<GhnApiResponseDto<List<GhnWardDto>>> GetWardsAsync(int districtId)
        {
            if (districtId <= 0)
            {
                return GhnApiResponseDto<List<GhnWardDto>>.Fail("Invalid district");
            }

            var response = await SendAsync(
                HttpMethod.Post,
                "/master-data/ward",
                new { district_id = districtId },
                false
            );

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<List<GhnWardDto>>.Fail(response.Message);
            }

            var items = DataArray(response.Root.Value)
                .Select(e => new GhnWardDto
                {
                    WardCode = GetString(e, "WardCode") ?? string.Empty,
                    DistrictId = GetInt(e, "DistrictID"),
                    WardName = GetString(e, "WardName") ?? string.Empty
                })
                .Where(w => !string.IsNullOrWhiteSpace(w.WardCode) && !string.IsNullOrWhiteSpace(w.WardName))
                .ToList();

            return GhnApiResponseDto<List<GhnWardDto>>.Ok(items);
        }

        public async Task<GhnApiResponseDto<GhnCalculateFeeResponseDto>> CalculateFeeAsync(
            GhnCalculateFeeRequestDto request)
        {
            if (request.ToDistrictId <= 0 || string.IsNullOrWhiteSpace(request.ToWardCode))
            {
                return GhnApiResponseDto<GhnCalculateFeeResponseDto>.Fail(
                    "Cannot calculate shipping fee. Please check delivery address."
                );
            }

            var package = BuildPackage(request.Items);
            var body = new
            {
                service_type_id = request.ServiceTypeId ?? _settings.ServiceTypeId,
                insurance_value = request.InsuranceValue ?? _settings.InsuranceValueDefault,
                coupon = (string?)null,
                from_district_id = _settings.FromDistrictId,
                to_district_id = request.ToDistrictId,
                to_ward_code = request.ToWardCode.Trim(),
                height = package.Height,
                length = package.Length,
                weight = package.Weight,
                width = package.Width
            };

            var response = await SendAsync(HttpMethod.Post, "/v2/shipping-order/fee", body, true);

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<GhnCalculateFeeResponseDto>.Fail(
                    "Cannot calculate shipping fee. Please check delivery address."
                );
            }

            var data = GetDataObject(response.Root.Value);
            var fee = new GhnCalculateFeeResponseDto
            {
                ShippingFee = GetDecimal(data, "total"),
                ServiceFee = GetDecimal(data, "service_fee"),
                InsuranceFee = GetDecimal(data, "insurance_fee"),
                ExpectedDeliveryTime = GetDateTime(data, "expected_delivery_time")
            };

            return fee.ShippingFee > 0
                ? GhnApiResponseDto<GhnCalculateFeeResponseDto>.Ok(fee)
                : GhnApiResponseDto<GhnCalculateFeeResponseDto>.Fail("Cannot calculate shipping fee. Please check delivery address.");
        }

        public async Task<GhnApiResponseDto<GhnCreateOrderResponseDto>> CreateOrderAsync(
            GhnCreateOrderRequestDto request)
        {
            var body = new
            {
                payment_type_id = request.PaymentTypeId,
                note = string.Empty,
                required_note = request.RequiredNote,
                from_name = _settings.FromName,
                from_phone = _settings.FromPhone,
                from_address = _settings.FromAddress,
                from_ward_name = _settings.FromWardCode,
                from_district_id = _settings.FromDistrictId,
                to_name = request.ToName,
                to_phone = request.ToPhone,
                to_address = request.ToAddress,
                to_ward_code = request.ToWardCode,
                to_district_id = request.ToDistrictId,
                cod_amount = request.CodAmount,
                content = request.Content,
                weight = request.Weight,
                length = request.Length,
                width = request.Width,
                height = request.Height,
                insurance_value = request.InsuranceValue,
                service_type_id = request.ServiceTypeId,
                client_order_code = request.ClientOrderCode,
                items = request.Items.Select(i => new
                {
                    name = i.Name,
                    quantity = i.Quantity,
                    price = i.Price,
                    weight = i.Weight
                }).ToList()
            };

            var response = await SendAsync(HttpMethod.Post, "/v2/shipping-order/create", body, true);

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<GhnCreateOrderResponseDto>.Fail(
                    "Cannot create GHN shipment. Please try again later."
                );
            }

            var data = GetDataObject(response.Root.Value);
            var result = new GhnCreateOrderResponseDto
            {
                GhnOrderCode = GetString(data, "order_code") ?? string.Empty,
                TotalFee = GetDecimal(data, "total_fee"),
                ExpectedDeliveryTime = GetDateTime(data, "expected_delivery_time"),
                Status = GetString(data, "status")
            };

            return string.IsNullOrWhiteSpace(result.GhnOrderCode)
                ? GhnApiResponseDto<GhnCreateOrderResponseDto>.Fail("Cannot create GHN shipment. Please try again later.")
                : GhnApiResponseDto<GhnCreateOrderResponseDto>.Ok(result);
        }

        public async Task<GhnApiResponseDto<GhnTrackingDto>> GetTrackingAsync(string ghnOrderCode)
        {
            if (string.IsNullOrWhiteSpace(ghnOrderCode))
            {
                return GhnApiResponseDto<GhnTrackingDto>.Fail("GHN order code is required");
            }

            var response = await SendAsync(
                HttpMethod.Post,
                "/v2/shipping-order/detail",
                new { order_code = ghnOrderCode.Trim() },
                true
            );

            if (!response.Success || response.Root == null)
            {
                return GhnApiResponseDto<GhnTrackingDto>.Fail("Cannot load GHN tracking.");
            }

            var data = GetDataObject(response.Root.Value);
            var status = GetString(data, "status");

            return GhnApiResponseDto<GhnTrackingDto>.Ok(new GhnTrackingDto
            {
                GhnOrderCode = ghnOrderCode.Trim(),
                Status = MapGhnStatus(status),
                StatusText = status,
                RawStatus = status,
                LeadTime = GetDateTime(data, "leadtime")
            });
        }

        public (int Weight, int Length, int Width, int Height) BuildPackage(IReadOnlyCollection<GhnFeeItemDto> items)
        {
            var quantity = Math.Max(1, items.Sum(i => Math.Max(1, i.Quantity)));
            var weight = items.Sum(i => Math.Max(1, i.Quantity) * (i.Weight ?? _settings.DefaultWeight));

            return (
                Math.Max(_settings.DefaultWeight, weight),
                _settings.DefaultLength,
                _settings.DefaultWidth,
                Math.Max(_settings.DefaultHeight, _settings.DefaultHeight * Math.Min(quantity, 4))
            );
        }

        private async Task<GhnHttpResult> SendAsync(
            HttpMethod method,
            string path,
            object? body,
            bool includeShopId)
        {
            var configurationErrors = GetConfigurationErrors();
            if (configurationErrors.Count > 0)
            {
                _logger.LogError(
                    "GHN is not configured. Invalid settings: {InvalidSettings}",
                    string.Join(", ", configurationErrors)
                );
                return GhnHttpResult.Fail("GHN is not configured");
            }

            var client = _httpClientFactory.CreateClient("GHN");
            client.BaseAddress = new Uri(_settings.BaseUrl.TrimEnd('/') + "/");
            client.Timeout = TimeSpan.FromSeconds(Math.Max(5, _settings.TimeoutSeconds));

            using var request = new HttpRequestMessage(method, path.TrimStart('/'));
            request.Headers.TryAddWithoutValidation("Token", _settings.Token);

            if (includeShopId)
            {
                request.Headers.TryAddWithoutValidation("ShopId", _settings.ShopId.ToString(CultureInfo.InvariantCulture));
                request.Headers.TryAddWithoutValidation("shop_id", _settings.ShopId.ToString(CultureInfo.InvariantCulture));
            }

            if (body != null)
            {
                request.Content = new StringContent(
                    JsonSerializer.Serialize(body),
                    Encoding.UTF8,
                    "application/json"
                );
            }

            try
            {
                using var response = await client.SendAsync(request);
                var content = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("GHN request {Path} failed with {Status}: {Content}", path, response.StatusCode, content);
                    return GhnHttpResult.Fail("GHN request failed");
                }

                using var document = JsonDocument.Parse(content);
                var root = document.RootElement.Clone();
                var code = GetInt(root, "code");

                if (code != 200)
                {
                    var message = GetString(root, "message") ?? "GHN request failed";
                    _logger.LogWarning("GHN request {Path} returned code {Code}: {Message}", path, code, message);
                    return GhnHttpResult.Fail(message);
                }

                return GhnHttpResult.Ok(root);
            }
            catch (TaskCanceledException ex)
            {
                _logger.LogWarning(ex, "GHN request {Path} timed out", path);
                return GhnHttpResult.Fail("GHN timeout");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GHN request {Path} failed", path);
                return GhnHttpResult.Fail("GHN request failed");
            }
        }

        private List<string> GetConfigurationErrors()
        {
            var errors = new List<string>();

            if (string.IsNullOrWhiteSpace(_settings.BaseUrl))
                errors.Add("BaseUrl");
            if (string.IsNullOrWhiteSpace(_settings.Token) ||
                _settings.Token.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
                errors.Add("Token");
            if (_settings.ShopId <= 0)
                errors.Add("ShopId");
            if (_settings.FromDistrictId <= 0)
                errors.Add("FromDistrictId");
            if (string.IsNullOrWhiteSpace(_settings.FromWardCode) ||
                _settings.FromWardCode.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
                errors.Add("FromWardCode");

            return errors;
        }

        private static IEnumerable<JsonElement> DataArray(JsonElement root)
        {
            if (root.TryGetProperty("data", out var data) && data.ValueKind == JsonValueKind.Array)
            {
                return data.EnumerateArray();
            }

            return Enumerable.Empty<JsonElement>();
        }

        private static JsonElement GetDataObject(JsonElement root)
        {
            return root.TryGetProperty("data", out var data) && data.ValueKind == JsonValueKind.Object
                ? data
                : root;
        }

        private static int GetInt(JsonElement element, string name)
        {
            if (!element.TryGetProperty(name, out var value))
            {
                return 0;
            }

            return value.ValueKind switch
            {
                JsonValueKind.Number => value.TryGetInt32(out var number) ? number : 0,
                JsonValueKind.String => int.TryParse(value.GetString(), out var number) ? number : 0,
                _ => 0
            };
        }

        private static decimal GetDecimal(JsonElement element, string name)
        {
            if (!element.TryGetProperty(name, out var value))
            {
                return 0m;
            }

            return value.ValueKind switch
            {
                JsonValueKind.Number => value.TryGetDecimal(out var number) ? number : 0m,
                JsonValueKind.String => decimal.TryParse(value.GetString(), NumberStyles.Number, CultureInfo.InvariantCulture, out var number) ? number : 0m,
                _ => 0m
            };
        }

        private static string? GetString(JsonElement element, string name)
        {
            return element.TryGetProperty(name, out var value)
                ? value.ToString()
                : null;
        }

        private static DateTime? GetDateTime(JsonElement element, string name)
        {
            if (!element.TryGetProperty(name, out var value))
            {
                return null;
            }

            return DateTime.TryParse(value.ToString(), out var date)
                ? date
                : null;
        }

        private static string MapGhnStatus(string? status)
        {
            return status switch
            {
                "ready_to_pick" => "ReadyToPick",
                "picking" => "Picking",
                "picked" => "Shipped",
                "storing" or "transporting" or "sorting" => "InTransit",
                "delivering" => "OutForDelivery",
                "delivered" => "Delivered",
                "delivery_fail" or "cancel" or "exception" => "Failed",
                "waiting_to_return" or "return" or "returned" => "Returned",
                _ => "InTransit"
            };
        }

        private class GhnHttpResult
        {
            public bool Success { get; set; }

            public string Message { get; set; } = string.Empty;

            public JsonElement? Root { get; set; }

            public static GhnHttpResult Ok(JsonElement root)
            {
                return new GhnHttpResult { Success = true, Root = root };
            }

            public static GhnHttpResult Fail(string message)
            {
                return new GhnHttpResult { Success = false, Message = message };
            }
        }
    }
}
