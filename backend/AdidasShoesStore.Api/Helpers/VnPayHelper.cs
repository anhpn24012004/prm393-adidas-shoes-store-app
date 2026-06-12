using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace AdidasShoesStore.Api.Helpers
{
    public class VnPayHelper
    {
        public string CreatePaymentUrl(
            string baseUrl,
            string hashSecret,
            IDictionary<string, string> parameters)
        {
            var normalizedParameters = NormalizeParameters(parameters);
            var query = BuildQueryString(normalizedParameters);
            var secureHash = CreateSecureHash(
                hashSecret,
                query
            );

            return $"{baseUrl}?{query}&vnp_SecureHash={secureHash}";
        }

        public bool ValidateSecureHash(
            string hashSecret,
            IReadOnlyDictionary<string, string> parameters)
        {
            if (!parameters.TryGetValue("vnp_SecureHash", out var receivedHash) ||
                string.IsNullOrWhiteSpace(receivedHash))
            {
                return false;
            }

            var normalizedParameters = NormalizeParameters(parameters);
            var query = BuildQueryString(normalizedParameters);
            var calculatedHash = CreateSecureHash(
                hashSecret,
                query
            );

            return string.Equals(
                calculatedHash,
                receivedHash,
                StringComparison.OrdinalIgnoreCase
            );
        }

        private static string CreateSecureHash(
            string hashSecret,
            string query)
        {
            var keyBytes = Encoding.UTF8.GetBytes(hashSecret);
            var inputBytes = Encoding.UTF8.GetBytes(query);

            using var hmac = new HMACSHA512(keyBytes);
            var hashBytes = hmac.ComputeHash(inputBytes);

            return Convert.ToHexString(hashBytes).ToLower(CultureInfo.InvariantCulture);
        }

        private static SortedDictionary<string, string> NormalizeParameters(
            IEnumerable<KeyValuePair<string, string>> parameters)
        {
            return new SortedDictionary<string, string>(
                parameters
                    .Where(p =>
                        p.Key.StartsWith("vnp_", StringComparison.OrdinalIgnoreCase) &&
                        !string.Equals(p.Key, "vnp_SecureHash", StringComparison.OrdinalIgnoreCase) &&
                        !string.Equals(p.Key, "vnp_SecureHashType", StringComparison.OrdinalIgnoreCase) &&
                        !string.IsNullOrWhiteSpace(p.Value))
                    .ToDictionary(
                        p => p.Key,
                        p => p.Value,
                        StringComparer.Ordinal
                    ),
                StringComparer.Ordinal
            );
        }

        private static string BuildQueryString(IEnumerable<KeyValuePair<string, string>> parameters)
        {
            return string.Join(
                "&",
                parameters.Select(p =>
                    $"{Uri.EscapeDataString(p.Key)}={Uri.EscapeDataString(p.Value)}")
            );
        }
    }
}
