using AdidasShoesStore.Api.Models;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public interface IEmailService
    {
        Task SendInvoiceEmailAsync(Order order);

        Task SendOtpEmailAsync(string toEmail, string otp);
    }
}
