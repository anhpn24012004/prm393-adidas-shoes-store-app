using AdidasShoesStore.Api.DTOs.Auth;
using AdidasShoesStore.Api.Services.Interfaces;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net.Mail;
using System.Security.Claims;
using System.Threading.Tasks;

namespace AdidasShoesStore.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IConfiguration _configuration;

        public AuthController(
            IAuthService authService,
            IConfiguration configuration)
        {
            _authService = authService;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequestDto request)
        {
            var result = await _authService.RegisterAsync(request);

            if (result == null)
            {
                return BadRequest(new
                {
                    message = "Email already exists or Customer role not found"
                });
            }

            return Ok(result);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequestDto request)
        {
            var result = await _authService.LoginAsync(request);

            if (result == null)
            {
                return Unauthorized(new
                {
                    message = "Invalid email or password"
                });
            }

            return Ok(result);
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleLogin(GoogleLoginRequestDto request)
        {
            try
            {
                var result = await _authService.GoogleLoginAsync(request);

                if (result == null)
                {
                    return Unauthorized(new
                    {
                        message = "Google account is invalid or inactive"
                    });
                }

                return Ok(result);
            }
            catch (InvalidJwtException)
            {
                return Unauthorized(new
                {
                    message = "Google ID token is invalid or expired"
                });
            }
            catch (InvalidOperationException exception)
            {
                return StatusCode(503, new { message = exception.Message });
            }
        }

        [HttpGet("google-config")]
        public IActionResult GoogleConfig()
        {
            var clientId = _configuration["GoogleAuth:ClientId"];
            var configured =
                !string.IsNullOrWhiteSpace(clientId) &&
                !clientId.StartsWith(
                    "YOUR_",
                    StringComparison.OrdinalIgnoreCase
                );

            return Ok(new
            {
                configured,
                clientId = configured ? clientId : null
            });
        }

        [Authorize]
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword(ChangePasswordDto request)
        {
            var userIdValue = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (!int.TryParse(userIdValue, out var userId))
            {
                return Unauthorized(new { message = "Invalid access token" });
            }

            var result = await _authService.ChangePasswordAsync(userId, request);

            if (!result)
            {
                return BadRequest(new
                {
                    message = "Current password is incorrect"
                });
            }

            return Ok(new { message = "Password changed successfully" });
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(
            ForgotPasswordRequestDto request)
        {
            try
            {
                var result = await _authService.ForgotPasswordAsync(request.Email);

                if (!result)
                {
                    return BadRequest(new
                    {
                        message = "Email này chưa đăng ký tài khoản."
                    });
                }

                return Ok(new
                {
                    message = "Mã OTP đã được gửi về email."
                });
            }
            catch (InvalidOperationException exception)
            {
                return StatusCode(503, new { message = exception.Message });
            }
            catch (SmtpException exception)
            {
                return StatusCode(503, new
                {
                    message = "Không thể gửi mã OTP. Vui lòng kiểm tra cấu hình Gmail SMTP.",
                    detail = exception.Message,
                    hint = "Hãy bật xác minh 2 bước và sử dụng Google App Password 16 ký tự, không dùng mật khẩu Gmail thông thường."
                });
            }
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword(ResetPasswordDto request)
        {
            var result = await _authService.ResetPasswordAsync(request);

            if (!result)
            {
                return BadRequest(new
                {
                    message = "Invalid or expired token"
                });
            }

            return Ok(new
            {
                message = "Password reset successfully"
            });
        }
    }
}
