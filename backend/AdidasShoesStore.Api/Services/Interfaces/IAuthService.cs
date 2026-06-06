using AdidasShoesStore.Api.DTOs.Auth;
using System.Threading.Tasks;

namespace AdidasShoesStore.Api.Services.Interfaces
{
    public interface IAuthService
    {
        Task<AuthResponseDto?> RegisterAsync(RegisterRequestDto request);
        Task<AuthResponseDto?> LoginAsync(LoginRequestDto request);
    }
}
