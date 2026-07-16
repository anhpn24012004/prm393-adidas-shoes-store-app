namespace AdidasShoesStore.Api.Settings;

public class PaymentSettings
{
    public int PendingPaymentExpireMinutes { get; set; } = 30;

    public int ExpirationScanIntervalMinutes { get; set; } = 5;
}
