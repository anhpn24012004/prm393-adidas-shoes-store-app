namespace AdidasShoesStore.Api.Settings;

public class SePaySettings
{
    public string ApiKey { get; set; } = string.Empty;

    public string WebhookSecret { get; set; } = string.Empty;

    public string BankAccountNumber { get; set; } = string.Empty;

    public string BankCode { get; set; } = string.Empty;

    public string AccountName { get; set; } = string.Empty;

    public string PaymentContentPrefix { get; set; } = "ADIDAS";
}
