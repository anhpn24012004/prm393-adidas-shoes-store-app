using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.UserAddresses;

public class SaveUserAddressDto
{
    [Required]
    [MaxLength(100)]
    public string ReceiverName { get; set; } = string.Empty;

    [Required]
    [MaxLength(20)]
    [RegularExpression(@"^[0-9+()\-\s]{8,20}$")]
    public string Phone { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    public string AddressLine { get; set; } = string.Empty;

    [MaxLength(100)]
    public string? Ward { get; set; }

    [MaxLength(100)]
    public string? District { get; set; }

    [MaxLength(100)]
    public string? City { get; set; }

    public int? ProvinceId { get; set; }

    public int? DistrictId { get; set; }

    [MaxLength(20)]
    public string? WardCode { get; set; }

    public bool IsDefault { get; set; }
}
