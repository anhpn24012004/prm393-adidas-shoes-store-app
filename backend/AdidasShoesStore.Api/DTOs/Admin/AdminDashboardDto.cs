namespace AdidasShoesStore.Api.DTOs.Admin;

public class AdminDashboardDto
{
    public int TotalUsers { get; set; }

    public int ActiveUsers { get; set; }

    public int InactiveUsers { get; set; }

    public int TotalProducts { get; set; }

    public int TotalOrders { get; set; }

    public decimal TotalRevenue { get; set; }

    public int PendingOrders { get; set; }

    public int CompletedOrders { get; set; }

    public int TotalRefundRequests { get; set; }

    public int TotalReviews { get; set; }
}