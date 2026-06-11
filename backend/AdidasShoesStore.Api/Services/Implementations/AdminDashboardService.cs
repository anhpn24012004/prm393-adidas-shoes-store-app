using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Admin;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations;

public class AdminDashboardService : IAdminDashboardService
{
    private readonly AdidasShoesStoreContext _context;

    public AdminDashboardService(AdidasShoesStoreContext context)
    {
        _context = context;
    }

    public async Task<AdminDashboardDto> GetDashboardAsync()
    {
        var totalUsers = await _context.Users.CountAsync();

        var activeUsers = await _context.Users
            .CountAsync(u => u.IsActive == true);

        var inactiveUsers = await _context.Users
            .CountAsync(u => u.IsActive == false);

        var totalProducts = await _context.Products.CountAsync();

        var totalOrders = await _context.Orders.CountAsync();

        var pendingOrders = await _context.Orders
            .CountAsync(o => o.Status == "Pending");

        var completedOrders = await _context.Orders
            .CountAsync(o => o.Status == "Completed");

        var totalRefundRequests = await _context.ReturnRequests.CountAsync();

        var totalReviews = await _context.Reviews.CountAsync();

        var totalRevenue = await _context.Orders
            .Where(o => o.Status == "Completed")
            .SumAsync(o => o.TotalAmount);

        return new AdminDashboardDto
        {
            TotalUsers = totalUsers,
            ActiveUsers = activeUsers,
            InactiveUsers = inactiveUsers,
            TotalProducts = totalProducts,
            TotalOrders = totalOrders,
            PendingOrders = pendingOrders,
            CompletedOrders = completedOrders,
            TotalRefundRequests = totalRefundRequests,
            TotalReviews = totalReviews,
            TotalRevenue = totalRevenue
        };
    }
}