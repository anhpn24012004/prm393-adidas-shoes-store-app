using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    public partial class ExtendReturnRequestsForManualReturnFlow : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
IF EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_ReturnRequests_OrderId'
      AND object_id = OBJECT_ID('dbo.ReturnRequests')
)
DROP INDEX [IX_ReturnRequests_OrderId] ON [dbo].[ReturnRequests];
");

            migrationBuilder.AddColumn<DateTime>(
                name: "ApprovedAt",
                table: "ReturnRequests",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "BankAccountName",
                table: "ReturnRequests",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BankAccountNumber",
                table: "ReturnRequests",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "BankName",
                table: "ReturnRequests",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "CustomerNote",
                table: "ReturnRequests",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "InspectionNote",
                table: "ReturnRequests",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsRestockable",
                table: "ReturnRequests",
                type: "bit",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ProcessedByAdminId",
                table: "ReturnRequests",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RefundTransactionNote",
                table: "ReturnRequests",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RefundedAt",
                table: "ReturnRequests",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RejectedAt",
                table: "ReturnRequests",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RequestCode",
                table: "ReturnRequests",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<decimal>(
                name: "RequestedAmount",
                table: "ReturnRequests",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "RestockQuantity",
                table: "ReturnRequests",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReturnCarrier",
                table: "ReturnRequests",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReturnReceivedAt",
                table: "ReturnRequests",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReturnShipmentNote",
                table: "ReturnRequests",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReturnShippedAt",
                table: "ReturnRequests",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ReturnTrackingCode",
                table: "ReturnRequests",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "RefundAmount",
                table: "ReturnItems",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPrice",
                table: "ReturnItems",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_OrderId_Status",
                table: "ReturnRequests",
                columns: new[] { "OrderId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_ProcessedByAdminId",
                table: "ReturnRequests",
                column: "ProcessedByAdminId");

            migrationBuilder.CreateIndex(
                name: "UQ_ReturnRequests_RequestCode",
                table: "ReturnRequests",
                column: "RequestCode",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_ReturnRequests_ProcessedByAdmin",
                table: "ReturnRequests",
                column: "ProcessedByAdminId",
                principalTable: "Users",
                principalColumn: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReturnRequests_ProcessedByAdmin",
                table: "ReturnRequests");

            migrationBuilder.DropIndex(
                name: "IX_ReturnRequests_OrderId_Status",
                table: "ReturnRequests");

            migrationBuilder.DropIndex(
                name: "IX_ReturnRequests_ProcessedByAdminId",
                table: "ReturnRequests");

            migrationBuilder.DropIndex(
                name: "UQ_ReturnRequests_RequestCode",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ApprovedAt",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "BankAccountName",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "BankAccountNumber",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "BankName",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "CustomerNote",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "InspectionNote",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "IsRestockable",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ProcessedByAdminId",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RefundTransactionNote",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RefundedAt",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RejectedAt",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RequestCode",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RequestedAmount",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RestockQuantity",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ReturnCarrier",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ReturnReceivedAt",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ReturnShipmentNote",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ReturnShippedAt",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "ReturnTrackingCode",
                table: "ReturnRequests");

            migrationBuilder.DropColumn(
                name: "RefundAmount",
                table: "ReturnItems");

            migrationBuilder.DropColumn(
                name: "UnitPrice",
                table: "ReturnItems");

            migrationBuilder.CreateIndex(
                name: "IX_ReturnRequests_OrderId",
                table: "ReturnRequests",
                column: "OrderId");
        }
    }
}
