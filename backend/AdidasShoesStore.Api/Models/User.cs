using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class User
{
    public int UserId { get; set; }

    public string FullName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public string? Phone { get; set; }

    public string? Gender { get; set; }

    public DateOnly? DateOfBirth { get; set; }

    public string? AvatarUrl { get; set; }

    public int RoleId { get; set; }

    public bool? IsActive { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? ResetPasswordToken { get; set; }

    public DateTime? ResetPasswordTokenExpires { get; set; }

    public string? ResetPasswordOtp { get; set; }

    public DateTime? ResetPasswordOtpExpiredAt { get; set; }

    public virtual ICollection<AirecommendationLog> AirecommendationLogs { get; set; } = new List<AirecommendationLog>();

    public virtual Cart? Cart { get; set; }

    public virtual ICollection<Order> Orders { get; set; } = new List<Order>();

    public virtual ICollection<ReturnRequest> ReturnRequests { get; set; } = new List<ReturnRequest>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual Role Role { get; set; } = null!;

    public virtual ICollection<UserAddress> UserAddresses { get; set; } = new List<UserAddress>();

    public virtual ICollection<Wishlist> Wishlists { get; set; } = new List<Wishlist>();
}
