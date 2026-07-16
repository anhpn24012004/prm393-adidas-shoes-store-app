using AdidasShoesStore.Api.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations;

[DbContext(typeof(AdidasShoesStoreContext))]
[Migration("20260622020000_AddProductVariantImageUrl")]
public partial class AddProductVariantImageUrl : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "ImageUrl",
            table: "ProductVariants",
            type: "nvarchar(500)",
            maxLength: 500,
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "OptionValuesJson",
            table: "ProductVariants",
            type: "nvarchar(max)",
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "ClassificationGroupsJson",
            table: "Products",
            type: "nvarchar(max)",
            nullable: true);

        migrationBuilder.AddColumn<int>(
            name: "VariantId",
            table: "Wishlists",
            type: "int",
            nullable: true);

        migrationBuilder.CreateIndex(
            name: "IX_Wishlists_VariantId",
            table: "Wishlists",
            column: "VariantId");

        migrationBuilder.AddForeignKey(
            name: "FK_Wishlists_ProductVariants_VariantId",
            table: "Wishlists",
            column: "VariantId",
            principalTable: "ProductVariants",
            principalColumn: "VariantId");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropForeignKey(
            name: "FK_Wishlists_ProductVariants_VariantId",
            table: "Wishlists");

        migrationBuilder.DropIndex(
            name: "IX_Wishlists_VariantId",
            table: "Wishlists");

        migrationBuilder.DropColumn(
            name: "VariantId",
            table: "Wishlists");

        migrationBuilder.DropColumn(
            name: "ImageUrl",
            table: "ProductVariants");

        migrationBuilder.DropColumn(
            name: "OptionValuesJson",
            table: "ProductVariants");

        migrationBuilder.DropColumn(
            name: "ClassificationGroupsJson",
            table: "Products");
    }
}
