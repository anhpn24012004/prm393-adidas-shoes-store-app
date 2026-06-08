using System.Globalization;
using System.Net;
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
            var secureHash = CreateSecureHash(
                hashSecret,
                parameters
            );

            var query = BuildQueryString(parameters);

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

            var data = parameters
                .Where(p =>
                    !string.Equals(p.Key, "vnp_SecureHash", StringComparison.OrdinalIgnoreCase) &&
                    !string.Equals(p.Key, "vnp_SecureHashType", StringComparison.OrdinalIgnoreCase) &&
                    !string.IsNullOrWhiteSpace(p.Value))
                .ToDictionary(p => p.Key, p => p.Value);

            var calculatedHash = CreateSecureHash(
                hashSecret,
                data
            );

            return string.Equals(
                calculatedHash,
                receivedHash,
                StringComparison.OrdinalIgnoreCase
            );
        }

        private static string CreateSecureHash(
            string hashSecret,
            IDictionary<string, string> parameters)
        {
            var hashData = BuildQueryString(parameters);
            var keyBytes = Encoding.UTF8.GetBytes(hashSecret);
            var inputBytes = Encoding.UTF8.GetBytes(hashData);

            using var hmac = new HMACSHA512(keyBytes);
            var hashBytes = hmac.ComputeHash(inputBytes);

            return Convert.ToHexString(hashBytes).ToLower(CultureInfo.InvariantCulture);
        }

        private static string BuildQueryString(IDictionary<string, string> parameters)
        {
            return string.Join(
                "&",
                parameters
                    .Where(p => !string.IsNullOrWhiteSpace(p.Value))
                    .OrderBy(p => p.Key, StringComparer.Ordinal)
                    .Select(p => $"{WebUtility.UrlEncode(p.Key)}={WebUtility.UrlEncode(p.Value)}")
            );
        }
    }
}
