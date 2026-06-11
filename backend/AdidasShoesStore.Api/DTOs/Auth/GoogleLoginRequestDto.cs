using System.ComponentModel.DataAnnotations;

namespace AdidasShoesStore.Api.DTOs.Auth;

public class GoogleLoginRequestDto
{
    [Required]
    public string IdToken { get; set; } = string.Empty;
}
