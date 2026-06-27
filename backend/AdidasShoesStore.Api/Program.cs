using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.Helpers;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Implementations;
using AdidasShoesStore.Api.Services.Interfaces;
using AdidasShoesStore.Api.Settings;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Net.Http.Headers;
using Microsoft.OpenApi.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// CORS for Flutter Web
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Swagger + JWT
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "Bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Enter JWT Token"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Register DbContext
builder.Services.AddDbContext<AdidasShoesStoreContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.Configure<GhnSettings>(builder.Configuration.GetSection("GhnSettings"));
builder.Services.Configure<SePaySettings>(builder.Configuration.GetSection("SePay"));
builder.Services.Configure<PaymentSettings>(builder.Configuration.GetSection("PaymentSettings"));
builder.Services.Configure<GhnSyncSettings>(builder.Configuration.GetSection("GhnSyncSettings"));
builder.Services.Configure<ShipmentSettings>(builder.Configuration.GetSection("ShipmentSettings"));
builder.Services.AddHttpClient("GHN");

// Register custom services
builder.Services.AddScoped<JwtHelper>();
builder.Services.AddScoped<VnPayHelper>();

builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddHttpClient<IAiAssistantService, AiAssistantService>();

builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IReturnRequestService, ReturnRequestService>();
builder.Services.AddScoped<IRefundService, RefundService>();
builder.Services.AddScoped<IRefundRequestService, RefundRequestService>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IShipmentService, ShipmentService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();
builder.Services.AddScoped<IGhnService, GhnService>();
builder.Services.AddScoped<ISePayService, SePayService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IAdminDashboardService, AdminDashboardService>();
builder.Services.AddHostedService<PendingPaymentExpirationService>();
builder.Services.AddHostedService<GhnShipmentSyncService>();

// Configure JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,

        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],

        IssuerSigningKey = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
        )
    };
});

// Add authorization
builder.Services.AddAuthorization();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// CORS must run before static files and Authentication/Authorization.
app.UseCors("AllowFlutterWeb");

app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = context =>
    {
        context.Context.Response.Headers[HeaderNames.AccessControlAllowOrigin] = "*";
    }
});

// Authentication must be before Authorization
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Seed admin in Development
if (app.Environment.IsDevelopment())
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<AdidasShoesStoreContext>();

    var adminRole = await context.Roles
        .FirstOrDefaultAsync(role => role.RoleName == "Admin");

    if (adminRole == null)
    {
        adminRole = new Role
        {
            RoleName = "Admin"
        };

        context.Roles.Add(adminRole);
        await context.SaveChangesAsync();
    }

    var adminEmail = "admin@adidas.com";

    var admin = await context.Users
        .FirstOrDefaultAsync(user => user.Email == adminEmail);

    if (admin == null)
    {
        context.Users.Add(new User
        {
            FullName = "Admin User",
            Email = adminEmail,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
            Phone = "0900000000",
            RoleId = adminRole.RoleId,
            IsActive = true,
            CreatedAt = DateTime.Now
        });

        await context.SaveChangesAsync();
    }
    else
    {
        admin.RoleId = adminRole.RoleId;
        admin.IsActive = true;

        await context.SaveChangesAsync();
    }
}

app.Run();
