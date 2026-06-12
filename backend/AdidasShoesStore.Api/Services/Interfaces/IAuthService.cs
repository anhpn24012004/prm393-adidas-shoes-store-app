using AdidasShoesStore.Api.DTOs.Auth;

namespace AdidasShoesStore.Api.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto?> RegisterAsync(RegisterRequestDto request);

    Task<AuthResponseDto?> LoginAsync(LoginRequestDto request);

    Task<AuthResponseDto?> GoogleLoginAsync(GoogleLoginRequestDto request);

    Task<bool> ChangePasswordAsync(int userId, ChangePasswordDto request);

    Task<bool> ForgotPasswordAsync(string email);

    Task<bool> ResetPasswordAsync(ResetPasswordDto request);
}
