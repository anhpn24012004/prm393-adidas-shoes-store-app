using AdidasShoesStore.Api.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations;

[DbContext(typeof(AdidasShoesStoreContext))]
[Migration("20260624090000_AllowNullProductVariantSku")]
public partial class AllowNullProductVariantSku : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.Sql(
            """
            DECLARE @dropSql nvarchar(max) = N'';

            SELECT @dropSql +=
                CASE
                    WHEN i.is_unique_constraint = 1
                        THEN N'ALTER TABLE [dbo].[ProductVariants] DROP CONSTRAINT ' + QUOTENAME(i.name) + N';'
                    ELSE N'DROP INDEX ' + QUOTENAME(i.name) + N' ON [dbo].[ProductVariants];'
                END
            FROM sys.indexes i
            INNER JOIN sys.index_columns ic
                ON ic.object_id = i.object_id
               AND ic.index_id = i.index_id
            INNER JOIN sys.columns c
                ON c.object_id = ic.object_id
               AND c.column_id = ic.column_id
            WHERE i.object_id = OBJECT_ID(N'[dbo].[ProductVariants]')
              AND i.is_unique = 1
              AND ic.key_ordinal > 0
              AND c.name = N'SKU'
              AND NOT EXISTS (
                  SELECT 1
                  FROM sys.index_columns other
                  WHERE other.object_id = i.object_id
                    AND other.index_id = i.index_id
                    AND other.key_ordinal > 0
                    AND other.column_id <> c.column_id
              );

            IF @dropSql <> N''
                EXEC sp_executesql @dropSql;

            UPDATE ProductVariants
            SET SKU = NULL
            WHERE SKU IS NOT NULL
              AND LTRIM(RTRIM(SKU)) = N'';

            UPDATE ProductVariants
            SET SKU = LTRIM(RTRIM(SKU))
            WHERE SKU IS NOT NULL;

            CREATE UNIQUE INDEX [UX_ProductVariants_SKU_NotNull]
                ON [dbo].[ProductVariants]([SKU])
                WHERE [SKU] IS NOT NULL;
            """);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "UX_ProductVariants_SKU_NotNull",
            table: "ProductVariants");

        migrationBuilder.CreateIndex(
            name: "UQ__ProductV__CA1ECF0D8EE27279",
            table: "ProductVariants",
            column: "SKU",
            unique: true,
            filter: "[SKU] IS NOT NULL");
    }
}
