using AdidasShoesStore.Api.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AdidasShoesStoreContext))]
    [Migration("20260627231530_CreateNotificationsTableIfMissing")]
    public partial class CreateNotificationsTableIfMissing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
IF OBJECT_ID(N'[dbo].[Notifications]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Notifications] (
        [NotificationId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [UserId] INT NULL,
        [Role] NVARCHAR(50) NULL,
        [Title] NVARCHAR(200) NOT NULL,
        [Message] NVARCHAR(1000) NOT NULL,
        [Type] NVARCHAR(100) NOT NULL,
        [IsRead] BIT NOT NULL DEFAULT CAST(0 AS bit),
        [CreatedAt] DATETIME2 NOT NULL,
        [ReadAt] DATETIME2 NULL,
        [RelatedOrderId] INT NULL,
        [RelatedPaymentId] INT NULL,
        [RelatedShipmentId] INT NULL,
        [RelatedRefundRequestId] INT NULL,
        [RelatedReturnRequestId] INT NULL,
        [RelatedProductId] INT NULL,
        [ActionUrl] NVARCHAR(500) NULL,
        [MetadataJson] NVARCHAR(MAX) NULL
    );

    CREATE INDEX [IX_Notifications_UserId] ON [dbo].[Notifications] ([UserId]);
    CREATE INDEX [IX_Notifications_Role] ON [dbo].[Notifications] ([Role]);
    CREATE INDEX [IX_Notifications_IsRead] ON [dbo].[Notifications] ([IsRead]);
    CREATE INDEX [IX_Notifications_CreatedAt] ON [dbo].[Notifications] ([CreatedAt]);
END
""");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
IF OBJECT_ID(N'[dbo].[Notifications]', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[Notifications];
END
""");
        }
    }
}
