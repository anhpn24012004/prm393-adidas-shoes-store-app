namespace AdidasShoesStore.Api.Settings
{
    public class GhnSettings
    {
        public string BaseUrl { get; set; } = string.Empty;

        public string Token { get; set; } = string.Empty;

        public int ShopId { get; set; }

        public int FromDistrictId { get; set; }

        public string FromWardCode { get; set; } = string.Empty;

        public string FromName { get; set; } = string.Empty;

        public string FromPhone { get; set; } = string.Empty;

        public string FromAddress { get; set; } = string.Empty;

        public int DefaultWeight { get; set; } = 800;

        public int DefaultLength { get; set; } = 35;

        public int DefaultWidth { get; set; } = 25;

        public int DefaultHeight { get; set; } = 15;

        public int InsuranceValueDefault { get; set; } = 1000000;

        public int ServiceTypeId { get; set; } = 2;

        public int PaymentTypeIdCod { get; set; } = 2;

        public int PaymentTypeIdOnline { get; set; } = 1;

        public string RequiredNote { get; set; } = "KHONGCHOXEMHANG";

        public int TimeoutSeconds { get; set; } = 20;
    }
}
