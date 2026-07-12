using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    public partial class AddResetPasswordOtpToUser : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Hai cột ResetPasswordOtp và ResetPasswordOtpExpiredAt
            // đã tồn tại trong database nên không tạo lại.
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Không xóa vì các cột đã tồn tại trước migration này.
        }
    }
}