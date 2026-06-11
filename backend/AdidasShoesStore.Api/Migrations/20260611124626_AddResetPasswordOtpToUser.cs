using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    public partial class AddResetPasswordOtpToUser : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ResetPasswordOtp",
                table: "Users",
                type: "nvarchar(6)",
                maxLength: 6,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ResetPasswordOtpExpiredAt",
                table: "Users",
                type: "datetime",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ResetPasswordOtp",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "ResetPasswordOtpExpiredAt",
                table: "Users");
        }
    }
}
