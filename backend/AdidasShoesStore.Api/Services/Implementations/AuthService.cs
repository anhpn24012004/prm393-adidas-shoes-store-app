using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Auth;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Google.Apis.Auth;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly AdidasShoesStoreContext _context;
        private readonly JwtHelper _jwtHelper;
        private readonly IEmailService _emailService;
        private readonly IConfiguration _configuration;

        public AuthService(
            AdidasShoesStoreContext context,
            JwtHelper jwtHelper,
            IEmailService emailService,
            IConfiguration configuration)
        {
            _context = context;
            _jwtHelper = jwtHelper;
            _emailService = emailService;
            _configuration = configuration;
        }

        public async Task<AuthResponseDto?> RegisterAsync(RegisterRequestDto request)
        {
            var email = request.Email.Trim().ToLower();

            var existedUser = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

            if (existedUser != null)
            {
                return null;
            }

            var customerRole = await _context.Roles
                .FirstOrDefaultAsync(r => r.RoleName == "Customer");

            if (customerRole == null)
            {
                return null;
            }

            var user = new User
            {
                FullName = request.FullName.Trim(),
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                Phone = request.Phone,
                Gender = request.Gender,
                DateOfBirth = request.DateOfBirth,
                RoleId = customerRole.RoleId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var token = _jwtHelper.GenerateToken(user, customerRole.RoleName);

            return new AuthResponseDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Role = customerRole.RoleName,
                Token = token
            };
        }

        public async Task<AuthResponseDto?> LoginAsync(LoginRequestDto request)
        {
            var email = request.Email.Trim().ToLower();

            var user = await _context.Users
                .Include(u => u. Role)
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null || user.IsActive == false)
            {
                return null;
            }

            var hasBcryptPassword = user.PasswordHash.StartsWith(
                "$2",
                StringComparison.Ordinal
            );

            var isPasswordValid = hasBcryptPassword
                ? BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash)
                : request.Password == user.PasswordHash;

            if (!isPasswordValid)
            {
                return null;
            }

            // Upgrade legacy seed-data passwords to BCrypt after first login.
            if (!hasBcryptPassword)
            {
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(
                    request.Password
                );
                await _context.SaveChangesAsync();
            }

            var roleName = user.Role.RoleName;

            var token = _jwtHelper.GenerateToken(user, roleName);

            return new AuthResponseDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Role = roleName,
                Token = token
            };
        }

        public async Task<AuthResponseDto?> GoogleLoginAsync(
            GoogleLoginRequestDto request)
        {
            var clientId = _configuration["GoogleAuth:ClientId"];

            if (string.IsNullOrWhiteSpace(clientId) ||
                clientId.StartsWith("YOUR_", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException(
                    "Google OAuth client ID is not configured."
                );
            }

            var payload = await GoogleJsonWebSignature.ValidateAsync(
                request.IdToken,
                new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { clientId }
                }
            );

            if (string.IsNullOrWhiteSpace(payload.Email) ||
                payload.EmailVerified != true)
            {
                return null;
            }

            var email = payload.Email.Trim().ToLowerInvariant();
            var user = await _context.Users
                .Include(existingUser => existingUser.Role)
                .FirstOrDefaultAsync(existingUser => existingUser.Email == email);

            if (user == null)
            {
                var customerRole = await _context.Roles
                    .FirstOrDefaultAsync(role => role.RoleName == "Customer");

                if (customerRole == null)
                {
                    throw new InvalidOperationException(
                        "Customer role was not found."
                    );
                }

                user = new User
                {
                    FullName = string.IsNullOrWhiteSpace(payload.Name)
                        ? email.Split('@')[0]
                        : payload.Name,
                    Email = email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(
                        Convert.ToHexString(RandomNumberGenerator.GetBytes(32))
                    ),
                    AvatarUrl = payload.Picture,
                    RoleId = customerRole.RoleId,
                    Role = customerRole,
                    IsActive = true,
                    CreatedAt = DateTime.Now
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }
            else
            {
                if (user.IsActive == false)
                {
                    return null;
                }

                if (!string.IsNullOrWhiteSpace(payload.Name))
                {
                    user.FullName = payload.Name;
                }

                if (!string.IsNullOrWhiteSpace(payload.Picture))
                {
                    user.AvatarUrl = payload.Picture;
                }

                await _context.SaveChangesAsync();
            }

            var roleName = user.Role.RoleName;
            var token = _jwtHelper.GenerateToken(user, roleName);

            return new AuthResponseDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Role = roleName,
                Token = token
            };
        }

        public async Task<UserProfileDto?> GetProfileAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            return user == null ? null : ToProfileDto(user);
        }

        public async Task<UserProfileDto?> UpdateProfileAsync(
            int userId,
            UpdateProfileDto request)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
            {
                return null;
            }

            user.FullName = request.FullName.Trim();
            user.Phone = string.IsNullOrWhiteSpace(request.Phone)
                ? null
                : request.Phone.Trim();
            user.Gender = string.IsNullOrWhiteSpace(request.Gender)
                ? null
                : request.Gender.Trim();
            user.DateOfBirth = request.DateOfBirth;

            await _context.SaveChangesAsync();

            return ToProfileDto(user);
        }

        public async Task<bool> ChangePasswordAsync(int userId, ChangePasswordDto request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.UserId == userId);

            if (user == null)
            {
                return false;
            }

            var hasBcryptPassword = user.PasswordHash.StartsWith(
                "$2",
                StringComparison.Ordinal
            );

            var isCurrentPasswordValid = hasBcryptPassword
                ? BCrypt.Net.BCrypt.Verify(
                    request.CurrentPassword,
                    user.PasswordHash
                )
                : request.CurrentPassword == user.PasswordHash;

            if (!isCurrentPasswordValid)
            {
                return false;
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ForgotPasswordAsync(string email)
        {
            email = email.Trim().ToLowerInvariant();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return true;
            }

            var now = DateTime.UtcNow;
            if (user.ResetPasswordOtpLastSentAt.HasValue &&
                now - user.ResetPasswordOtpLastSentAt.Value.ToUniversalTime() < TimeSpan.FromSeconds(60))
            {
                return true;
            }

            var otp = RandomNumberGenerator.GetInt32(100000, 1000000)
                .ToString();

            user.ResetPasswordOtp = otp;
            user.ResetPasswordOtpExpiredAt = now.AddMinutes(5);
            user.ResetPasswordOtpLastSentAt = now;
            user.ResetPasswordOtpFailedAttempts = 0;

            await _context.SaveChangesAsync();
            await _emailService.SendOtpEmailAsync(user.Email, otp);

            return true;
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordDto request)
        {
            var email = request.Email.Trim().ToLower();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == email);

            if (user == null)
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(user.ResetPasswordOtp) ||
                user.ResetPasswordOtp != request.Token.Trim())
            {
                user.ResetPasswordOtpFailedAttempts += 1;

                if (user.ResetPasswordOtpFailedAttempts >= 5)
                {
                    user.ResetPasswordOtp = null;
                    user.ResetPasswordOtpExpiredAt = null;
                }

                await _context.SaveChangesAsync();
                return false;
            }

            if (user.ResetPasswordOtpExpiredAt == null ||
                user.ResetPasswordOtpExpiredAt.Value.ToUniversalTime() < DateTime.UtcNow ||
                user.ResetPasswordOtpFailedAttempts >= 5)
            {
                return false;
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.ResetPasswordOtp = null;
            user.ResetPasswordOtpExpiredAt = null;
            user.ResetPasswordOtpLastSentAt = null;
            user.ResetPasswordOtpFailedAttempts = 0;

            await _context.SaveChangesAsync();

            return true;
        }

        private static UserProfileDto ToProfileDto(User user)
        {
            return new UserProfileDto
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Phone = user.Phone,
                Gender = user.Gender,
                DateOfBirth = user.DateOfBirth,
                Role = user.Role.RoleName
            };
        }

    }
}
