using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddRefundRequests : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "RefundRequests",
                columns: table => new
                {
                    RefundRequestId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<int>(type: "int", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RequestCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Reason = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RequestedAmount = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    BankName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    BankAccountNumber = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    BankAccountName = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CustomerNote = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Status = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())"),
                    ApprovedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RejectedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    RefundedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ProcessedByAdminId = table.Column<int>(type: "int", nullable: true),
                    ProofImageUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    RefundTransactionNote = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    AdminNote = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__RefundReq__0CCD259900000001", x => x.RefundRequestId);
                    table.ForeignKey(
                        name: "FK_RefundRequests_Orders",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "OrderId");
                    table.ForeignKey(
                        name: "FK_RefundRequests_ProcessedByAdmin",
                        column: x => x.ProcessedByAdminId,
                        principalTable: "Users",
                        principalColumn: "UserId");
                    table.ForeignKey(
                        name: "FK_RefundRequests_Users",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_RefundRequests_OrderId_Status",
                table: "RefundRequests",
                columns: new[] { "OrderId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_RefundRequests_ProcessedByAdminId",
                table: "RefundRequests",
                column: "ProcessedByAdminId");

            migrationBuilder.CreateIndex(
                name: "IX_RefundRequests_UserId",
                table: "RefundRequests",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "UQ_RefundRequests_RequestCode",
                table: "RefundRequests",
                column: "RequestCode",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "RefundRequests");
        }
    }
}
