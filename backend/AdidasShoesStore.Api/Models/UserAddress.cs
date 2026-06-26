using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class UserAddress
{
    public int AddressId { get; set; }

    public int UserId { get; set; }

    public string ReceiverName { get; set; } = null!;

    public string Phone { get; set; } = null!;

    public string AddressLine { get; set; } = null!;

    public string? Ward { get; set; }

    public string? District { get; set; }

    public string? City { get; set; }

    public int? ProvinceId { get; set; }

    public int? DistrictId { get; set; }

    public string? WardCode { get; set; }

    public bool? IsDefault { get; set; }

    public virtual User User { get; set; } = null!;
}
