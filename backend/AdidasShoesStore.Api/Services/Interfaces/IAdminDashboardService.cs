using AdidasShoesStore.Api.DTOs.Admin;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IAdminDashboardService
{
    Task<AdminDashboardDto> GetDashboardAsync();
}