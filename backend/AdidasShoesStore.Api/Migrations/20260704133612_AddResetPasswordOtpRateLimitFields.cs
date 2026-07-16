using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddResetPasswordOtpRateLimitFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ResetPasswordOtpFailedAttempts",
                table: "Users",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "ResetPasswordOtpLastSentAt",
                table: "Users",
                type: "datetime",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ResetPasswordOtpFailedAttempts",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ResetPasswordOtpLastSentAt",
                table: "Users");
        }
    }
}
