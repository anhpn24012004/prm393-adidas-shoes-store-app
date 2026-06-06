using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Auth;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Threading.Tasks;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class AuthService : IAuthService
    {
        private readonly AdidasShoesStoreContext _context;
        private readonly JwtHelper _jwtHelper;

        public AuthService(AdidasShoesStoreContext context, JwtHelper jwtHelper)
        {
            _context = context;
            _jwtHelper = jwtHelper;
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

            var isPasswordValid = BCrypt.Net.BCrypt.Verify(
                request.Password,
                user.PasswordHash
            );

            if (!isPasswordValid)
            {
                return null;
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
    }
}
