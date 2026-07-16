using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddGhnShippingIntegration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ExpectedDeliveryTime",
                table: "Shipments",
                type: "datetime",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GhnOrderCode",
                table: "Shipments",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RawGhnStatus",
                table: "Shipments",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "ShippingFee",
                table: "Shipments",
                type: "decimal(18,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "ToDistrictId",
                table: "Orders",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ToDistrictName",
                table: "Orders",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ToProvinceName",
                table: "Orders",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ToWardCode",
                table: "Orders",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ToWardName",
                table: "Orders",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ExpectedDeliveryTime",
                table: "Shipments");

            migrationBuilder.DropColumn(
                name: "GhnOrderCode",
                table: "Shipments");

            migrationBuilder.DropColumn(
                name: "RawGhnStatus",
                table: "Shipments");

            migrationBuilder.DropColumn(
                name: "ShippingFee",
                table: "Shipments");

            migrationBuilder.DropColumn(
                name: "ToDistrictId",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ToDistrictName",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ToProvinceName",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ToWardCode",
                table: "Orders");

            migrationBuilder.DropColumn(
                name: "ToWardName",
                table: "Orders");
        }
    }
}
