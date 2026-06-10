namespace AdidasShoesStore.Api.DTOs.Order
{
    public class RevenueSummaryDto
    {
        public int TotalOrders { get; set; }

        public int PaidOrders { get; set; }

        public int CancelledOrders { get; set; }

        public decimal TotalRevenue { get; set; }

        public decimal TodayRevenue { get; set; }

        public decimal MonthRevenue { get; set; }
    }
}
