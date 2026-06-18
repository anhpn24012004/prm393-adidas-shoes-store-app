namespace AdidasShoesStore.Api.DTOs.Users;

public class AdminUserDto
{
    public int UserId { get; set; }

    public string FullName { get; set; } = string.Empty;

    public string Email { get; set; } = string.Empty;

    public string? Phone { get; set; }

    public string? Gender { get; set; }

    public string RoleName { get; set; } = string.Empty;

    public bool IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int OrderCount { get; set; }

    public int ReturnRequestCount { get; set; }
}
