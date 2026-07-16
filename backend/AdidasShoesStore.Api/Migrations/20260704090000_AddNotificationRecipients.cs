using AdidasShoesStore.Api.Data;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AdidasShoesStore.Api.Migrations
{
    /// <inheritdoc />
    [DbContext(typeof(AdidasShoesStoreContext))]
    [Migration("20260704090000_AddNotificationRecipients")]
    public partial class AddNotificationRecipients : Migration
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
END

IF OBJECT_ID(N'[dbo].[NotificationRecipients]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[NotificationRecipients] (
        [NotificationRecipientId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [NotificationId] INT NOT NULL,
        [UserId] INT NOT NULL,
        [IsRead] BIT NOT NULL DEFAULT CAST(0 AS bit),
        [ReadAt] DATETIME2 NULL,
        [CreatedAt] DATETIME2 NOT NULL,
        CONSTRAINT [FK_NotificationRecipients_Notifications_NotificationId]
            FOREIGN KEY ([NotificationId]) REFERENCES [dbo].[Notifications] ([NotificationId]) ON DELETE CASCADE,
        CONSTRAINT [FK_NotificationRecipients_Users_UserId]
            FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users] ([UserId]) ON DELETE CASCADE
    );
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_NotificationRecipients_Notification_User' AND object_id = OBJECT_ID(N'[dbo].[NotificationRecipients]'))
    CREATE UNIQUE INDEX [UX_NotificationRecipients_Notification_User] ON [dbo].[NotificationRecipients] ([NotificationId], [UserId]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NotificationRecipients_UserId_IsRead' AND object_id = OBJECT_ID(N'[dbo].[NotificationRecipients]'))
    CREATE INDEX [IX_NotificationRecipients_UserId_IsRead] ON [dbo].[NotificationRecipients] ([UserId], [IsRead]);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_NotificationRecipients_CreatedAt' AND object_id = OBJECT_ID(N'[dbo].[NotificationRecipients]'))
    CREATE INDEX [IX_NotificationRecipients_CreatedAt] ON [dbo].[NotificationRecipients] ([CreatedAt]);

INSERT INTO [dbo].[NotificationRecipients] ([NotificationId], [UserId], [IsRead], [ReadAt], [CreatedAt])
SELECT n.[NotificationId], n.[UserId], n.[IsRead], n.[ReadAt], n.[CreatedAt]
FROM [dbo].[Notifications] n
WHERE n.[UserId] IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM [dbo].[NotificationRecipients] r
      WHERE r.[NotificationId] = n.[NotificationId] AND r.[UserId] = n.[UserId]
  );

INSERT INTO [dbo].[NotificationRecipients] ([NotificationId], [UserId], [IsRead], [ReadAt], [CreatedAt])
SELECT n.[NotificationId], u.[UserId], CAST(0 AS bit), NULL, n.[CreatedAt]
FROM [dbo].[Notifications] n
INNER JOIN [dbo].[Users] u ON u.[RoleId] = (
    SELECT TOP(1) [RoleId] FROM [dbo].[Roles] WHERE [RoleName] = n.[Role]
)
WHERE n.[UserId] IS NULL
  AND n.[Role] IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM [dbo].[NotificationRecipients] r
      WHERE r.[NotificationId] = n.[NotificationId] AND r.[UserId] = u.[UserId]
  );
""");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("""
IF OBJECT_ID(N'[dbo].[NotificationRecipients]', N'U') IS NOT NULL
BEGIN
    DROP TABLE [dbo].[NotificationRecipients];
END
""");
        }
    }
}
