using System.Net;
using System.Net.Mail;
using System.Text;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;

        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendInvoiceEmailAsync(Order order)
        {
            var config = GetEmailConfig();

            if (config == null)
            {
                return;
            }

            var subject = $"Invoice for order {order.OrderCode}";
            var body = BuildInvoiceHtml(order);

            using var message = new MailMessage
            {
                From = new MailAddress(config.From, config.FromName, Encoding.UTF8),
                Subject = subject,
                Body = body,
                IsBodyHtml = true
            };

            message.To.Add(order.User.Email);

            using var client = new SmtpClient(config.SmtpHost, config.SmtpPort)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(
                    config.Username,
                    config.Password
                )
            };

            await client.SendMailAsync(message);
        }

        public async Task SendOtpEmailAsync(string toEmail, string otp)
        {
            var config = GetEmailConfig()
                ?? throw new InvalidOperationException(
                    "Email SMTP settings are not configured."
                );

            using var message = new MailMessage
            {
                From = new MailAddress(config.From, config.FromName, Encoding.UTF8),
                Subject = "Mã OTP đặt lại mật khẩu Adidas",
                Body = $"""
                    <!doctype html>
                    <html>
                    <body style="font-family:Arial,sans-serif;color:#171717;">
                      <h2>Đặt lại mật khẩu</h2>
                      <p>Mã OTP xác thực của bạn là:</p>
                      <p style="font-size:32px;font-weight:700;letter-spacing:8px;">
                        {WebUtility.HtmlEncode(otp)}
                      </p>
                      <p>Mã OTP có hiệu lực trong 5 phút.</p>
                      <p>Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này.</p>
                    </body>
                    </html>
                    """,
                IsBodyHtml = true
            };

            message.To.Add(toEmail);

            using var client = new SmtpClient(config.SmtpHost, config.SmtpPort)
            {
                EnableSsl = true,
                UseDefaultCredentials = false,
                Credentials = new NetworkCredential(
                    config.Username,
                    config.Password
                )
            };

            await client.SendMailAsync(message);
        }

        private static string BuildInvoiceHtml(Order order)
        {
            var builder = new StringBuilder();

            builder.AppendLine("<!doctype html>");
            builder.AppendLine("<html><body style=\"font-family:Arial,sans-serif;color:#222;\">");
            builder.AppendLine($"<h2>Invoice #{WebUtility.HtmlEncode(order.OrderCode)}</h2>");
            builder.AppendLine("<p>Thank you for your payment.</p>");
            builder.AppendLine("<h3>Shipping information</h3>");
            builder.AppendLine("<table cellpadding=\"6\" cellspacing=\"0\">");
            builder.AppendLine($"<tr><td><strong>Customer</strong></td><td>{WebUtility.HtmlEncode(order.User.FullName)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Receiver</strong></td><td>{WebUtility.HtmlEncode(order.ReceiverName)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Receiver phone</strong></td><td>{WebUtility.HtmlEncode(order.ReceiverPhone)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Shipping address</strong></td><td>{WebUtility.HtmlEncode(order.ShippingAddress)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Payment method</strong></td><td>{WebUtility.HtmlEncode(order.Payment?.PaymentMethod ?? string.Empty)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Paid date</strong></td><td>{WebUtility.HtmlEncode(order.Payment?.PaidAt?.ToString("yyyy-MM-dd HH:mm:ss") ?? string.Empty)}</td></tr>");
            builder.AppendLine("</table>");

            builder.AppendLine("<h3>Order items</h3>");
            builder.AppendLine("<table cellpadding=\"8\" cellspacing=\"0\" border=\"1\" style=\"border-collapse:collapse;border-color:#ddd;\">");
            builder.AppendLine("<thead><tr><th align=\"left\">Product</th><th>Size</th><th>Color</th><th>Quantity</th><th align=\"right\">Unit price</th><th align=\"right\">Subtotal</th></tr></thead>");
            builder.AppendLine("<tbody>");

            foreach (var item in order.OrderItems)
            {
                builder.AppendLine("<tr>");
                builder.AppendLine($"<td>{WebUtility.HtmlEncode(item.ProductName)}</td>");
                builder.AppendLine($"<td>{WebUtility.HtmlEncode(item.Size)}</td>");
                builder.AppendLine($"<td>{WebUtility.HtmlEncode(item.Color)}</td>");
                builder.AppendLine($"<td align=\"center\">{item.Quantity}</td>");
                builder.AppendLine($"<td align=\"right\">{FormatMoney(item.UnitPrice)}</td>");
                builder.AppendLine($"<td align=\"right\">{FormatMoney(item.UnitPrice * item.Quantity)}</td>");
                builder.AppendLine("</tr>");
            }

            builder.AppendLine("</tbody>");
            builder.AppendLine("</table>");

            builder.AppendLine("<h3>Payment summary</h3>");
            builder.AppendLine("<table cellpadding=\"6\" cellspacing=\"0\">");
            builder.AppendLine($"<tr><td><strong>Total amount</strong></td><td align=\"right\">{FormatMoney(order.TotalAmount)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Shipping fee</strong></td><td align=\"right\">{FormatMoney(order.ShippingFee ?? 0m)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Discount amount</strong></td><td align=\"right\">{FormatMoney(order.DiscountAmount ?? 0m)}</td></tr>");
            builder.AppendLine($"<tr><td><strong>Final amount</strong></td><td align=\"right\">{FormatMoney(order.FinalAmount)}</td></tr>");
            builder.AppendLine("</table>");
            builder.AppendLine("</body></html>");

            return builder.ToString();
        }

        private static string FormatMoney(decimal amount)
        {
            return $"{amount:N0} VND";
        }

        private EmailConfig? GetEmailConfig()
        {
            var smtpHost = _configuration["Email:SmtpHost"];
            var username = _configuration["Email:Username"];
            var password = _configuration["Email:Password"];
            var from = _configuration["Email:From"];
            var fromName = _configuration["Email:FromName"];
            var portValue = _configuration["Email:SmtpPort"];

            if (string.IsNullOrWhiteSpace(smtpHost) ||
                string.IsNullOrWhiteSpace(username) ||
                string.IsNullOrWhiteSpace(password) ||
                string.IsNullOrWhiteSpace(from) ||
                username.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                password.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                from.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase) ||
                !int.TryParse(portValue, out var smtpPort))
            {
                return null;
            }

            return new EmailConfig
            {
                SmtpHost = smtpHost,
                SmtpPort = smtpPort,
                Username = username,
                Password = password,
                From = from,
                FromName = string.IsNullOrWhiteSpace(fromName)
                    ? "Adidas Shoes Store"
                    : fromName
            };
        }

        private class EmailConfig
        {
            public string SmtpHost { get; set; } = null!;

            public int SmtpPort { get; set; }

            public string Username { get; set; } = null!;

            public string Password { get; set; } = null!;

            public string From { get; set; } = null!;

            public string FromName { get; set; } = null!;
        }
    }
}
