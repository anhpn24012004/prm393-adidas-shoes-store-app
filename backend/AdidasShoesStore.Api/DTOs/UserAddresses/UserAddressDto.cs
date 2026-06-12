namespace AdidasShoesStore.Api.DTOs.UserAddresses;

public class UserAddressDto
{
    public int AddressId { get; set; }

    public string ReceiverName { get; set; } = string.Empty;

    public string Phone { get; set; } = string.Empty;

    public string AddressLine { get; set; } = string.Empty;

    public string? Ward { get; set; }

    public string? District { get; set; }

    public string? City { get; set; }

    public bool IsDefault { get; set; }
}
