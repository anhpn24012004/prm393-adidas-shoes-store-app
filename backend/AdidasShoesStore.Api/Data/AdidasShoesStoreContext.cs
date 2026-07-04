using System;
using System.Collections.Generic;
using AdidasShoesStore.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Data;

public partial class AdidasShoesStoreContext : DbContext
{
    public AdidasShoesStoreContext()
    {
    }

    public AdidasShoesStoreContext(DbContextOptions<AdidasShoesStoreContext> options)
        : base(options)
    {
    }

    public virtual DbSet<AirecommendationLog> AirecommendationLogs { get; set; }

    public virtual DbSet<Cart> Carts { get; set; }

    public virtual DbSet<CartItem> CartItems { get; set; }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Order> Orders { get; set; }

    public virtual DbSet<OrderItem> OrderItems { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<Product> Products { get; set; }

    public virtual DbSet<ProductImage> ProductImages { get; set; }

    public virtual DbSet<ProductVariant> ProductVariants { get; set; }

    public virtual DbSet<Refund> Refunds { get; set; }

    public virtual DbSet<RefundRequest> RefundRequests { get; set; }

    public virtual DbSet<ReturnItem> ReturnItems { get; set; }

    public virtual DbSet<ReturnRequest> ReturnRequests { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Shipment> Shipments { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserAddress> UserAddresses { get; set; }

    public virtual DbSet<Wishlist> Wishlists { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<NotificationRecipient> NotificationRecipients { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer(
                "Server=localhost;Database=AdidasShoesStore;Trusted_Connection=True;TrustServerCertificate=True;"
            );
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<AirecommendationLog>(entity =>
        {
            entity.HasKey(e => e.LogId).HasName("PK__AIRecomm__5E54864851CCD469");

            entity.ToTable("AIRecommendationLogs");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.RecommendedProductIds).HasMaxLength(255);
            entity.Property(e => e.RecommendedSize).HasMaxLength(20);

            entity.HasOne(d => d.User).WithMany(p => p.AirecommendationLogs)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK__AIRecomme__UserI__09A971A2");
        });

        modelBuilder.Entity<Cart>(entity =>
        {
            entity.HasKey(e => e.CartId).HasName("PK__Carts__51BCD7B7604D00CF");

            entity.HasIndex(e => e.UserId, "UQ__Carts__1788CC4DD084CB69").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.User).WithOne(p => p.Cart)
                .HasForeignKey<Cart>(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Carts__UserId__571DF1D5");
        });

        modelBuilder.Entity<CartItem>(entity =>
        {
            entity.HasKey(e => e.CartItemId).HasName("PK__CartItem__488B0B0ACC5D589A");

            entity.HasOne(d => d.Cart).WithMany(p => p.CartItems)
                .HasForeignKey(d => d.CartId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CartItems__CartI__5AEE82B9");

            entity.HasOne(d => d.Variant).WithMany(p => p.CartItems)
                .HasForeignKey(d => d.VariantId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__CartItems__Varia__5BE2A6F2");
        });

        modelBuilder.Entity<Category>(entity =>
        {
            entity.HasKey(e => e.CategoryId).HasName("PK__Categori__19093A0BC5FCE180");

            entity.Property(e => e.CategoryName).HasMaxLength(100);
            entity.Property(e => e.Description).HasMaxLength(255);
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.HasKey(e => e.OrderId).HasName("PK__Orders__C3905BCFD549CAEB");

            entity.HasIndex(e => e.OrderCode, "UQ__Orders__999B5229F20410BF").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DiscountAmount)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.FinalAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Note).HasMaxLength(255);
            entity.Property(e => e.OrderCode).HasMaxLength(50);
            entity.Property(e => e.ReceiverName).HasMaxLength(100);
            entity.Property(e => e.ReceiverPhone).HasMaxLength(20);
            entity.Property(e => e.ShippingAddress).HasMaxLength(255);
            entity.Property(e => e.ShippingFee)
                .HasDefaultValue(0m)
                .HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.ToDistrictName).HasMaxLength(100);
            entity.Property(e => e.ToProvinceName).HasMaxLength(100);
            entity.Property(e => e.ToWardCode).HasMaxLength(20);
            entity.Property(e => e.ToWardName).HasMaxLength(100);
            entity.Property(e => e.TotalAmount).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.User).WithMany(p => p.Orders)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Orders__UserId__628FA481");
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.HasKey(e => e.OrderItemId).HasName("PK__OrderIte__57ED0681596086EA");

            entity.Property(e => e.Color).HasMaxLength(50);
            entity.Property(e => e.ProductName).HasMaxLength(150);
            entity.Property(e => e.Size).HasMaxLength(20);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.Order).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__OrderItem__Order__656C112C");

            entity.HasOne(d => d.Variant).WithMany(p => p.OrderItems)
                .HasForeignKey(d => d.VariantId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__OrderItem__Varia__66603565");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__Payments__9B556A38D879DA3F");

            entity.HasIndex(e => e.OrderId, "UQ__Payments__C3905BCE48FC4ECF").IsUnique();
            entity.HasIndex(e => e.ProviderTransactionId)
                .IsUnique()
                .HasFilter("[ProviderTransactionId] IS NOT NULL");

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.PaidAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.PaidAt).HasColumnType("datetime");
            entity.Property(e => e.PaymentMethod).HasMaxLength(50);
            entity.Property(e => e.PaymentProvider).HasMaxLength(50);
            entity.Property(e => e.ProviderTransactionId).HasMaxLength(100);
            entity.Property(e => e.RawWebhookData).HasColumnType("nvarchar(max)");
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.TransactionCode).HasMaxLength(100);
            entity.Property(e => e.TransferContent).HasMaxLength(255);

            entity.HasOne(d => d.Order).WithOne(p => p.Payment)
                .HasForeignKey<Payment>(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Payments__OrderI__6A30C649");
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.HasKey(e => e.ProductId).HasName("PK__Products__B40CC6CD4C8ACE30");

            entity.Property(e => e.BasePrice).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Brand)
                .HasMaxLength(100)
                .HasDefaultValue("Adidas");
            entity.Property(e => e.ClassificationGroupsJson).HasColumnType("nvarchar(max)");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Gender).HasMaxLength(50);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Material).HasMaxLength(100);
            entity.Property(e => e.ProductName).HasMaxLength(150);

            entity.HasOne(d => d.Category).WithMany(p => p.Products)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Products__Catego__48CFD27E");
        });

        modelBuilder.Entity<ProductImage>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("PK__ProductI__7516F70C32BA1EBB");

            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.IsMain).HasDefaultValue(false);

            entity.HasOne(d => d.Product).WithMany(p => p.ProductImages)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ProductIm__Produ__52593CB8");
        });

        modelBuilder.Entity<ProductVariant>(entity =>
        {
            entity.HasKey(e => e.VariantId).HasName("PK__ProductV__0EA2338405E10B3D");

            entity.HasIndex(e => e.Sku, "UX_ProductVariants_SKU_NotNull")
                .IsUnique()
                .HasFilter("[SKU] IS NOT NULL");

            entity.Property(e => e.Color).HasMaxLength(50);
            entity.Property(e => e.ImageUrl).HasMaxLength(500);
            entity.Property(e => e.OptionValuesJson).HasColumnType("nvarchar(max)");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Price).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Size).HasMaxLength(20);
            entity.Property(e => e.Sku)
                .HasMaxLength(100)
                .HasColumnName("SKU");
            entity.Property(e => e.StockQuantity).HasDefaultValue(0);

            entity.HasOne(d => d.Product).WithMany(p => p.ProductVariants)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ProductVa__Produ__4E88ABD4");
        });

        modelBuilder.Entity<Refund>(entity =>
        {
            entity.HasKey(e => e.RefundId).HasName("PK__Refunds__725AB9206A92E9AD");

            entity.HasIndex(e => e.ReturnRequestId, "UQ__Refunds__0CCD2598112CDBB9").IsUnique();

            entity.Property(e => e.Amount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.PaymentMethod).HasMaxLength(50);
            entity.Property(e => e.RefundedAt).HasColumnType("datetime");
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.TransactionCode).HasMaxLength(100);

            entity.HasOne(d => d.Order).WithMany(p => p.Refunds)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Refunds__OrderId__7B5B524B");

            entity.HasOne(d => d.ReturnRequest).WithOne(p => p.Refund)
                .HasForeignKey<Refund>(d => d.ReturnRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Refunds__ReturnR__7A672E12");
        });

        modelBuilder.Entity<RefundRequest>(entity =>
        {
            entity.HasKey(e => e.RefundRequestId).HasName("PK__RefundReq__0CCD259900000001");

            entity.HasIndex(e => e.RequestCode, "UQ_RefundRequests_RequestCode").IsUnique();
            entity.HasIndex(e => new { e.OrderId, e.Status }, "IX_RefundRequests_OrderId_Status");

            entity.Property(e => e.AdminNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.BankAccountName).HasMaxLength(100);
            entity.Property(e => e.BankAccountNumber).HasMaxLength(50);
            entity.Property(e => e.BankName).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.ProofImageUrl).HasMaxLength(255);
            entity.Property(e => e.ProcessedByAdminId);
            entity.Property(e => e.Reason).HasColumnType("nvarchar(max)");
            entity.Property(e => e.RefundTransactionNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.RequestCode).HasMaxLength(50);
            entity.Property(e => e.RequestedAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.Status).HasMaxLength(50);

            entity.HasOne(d => d.Order).WithMany(p => p.RefundRequests)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundRequests_Orders");

            entity.HasOne(d => d.ProcessedByAdmin).WithMany(p => p.ProcessedRefundRequests)
                .HasForeignKey(d => d.ProcessedByAdminId)
                .OnDelete(DeleteBehavior.NoAction)
                .HasConstraintName("FK_RefundRequests_ProcessedByAdmin");

            entity.HasOne(d => d.User).WithMany(p => p.RefundRequests)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_RefundRequests_Users");
        });

        modelBuilder.Entity<ReturnItem>(entity =>
        {
            entity.HasKey(e => e.ReturnItemId).HasName("PK__ReturnIt__8D87CD3A9E325E86");

            entity.Property(e => e.Reason).HasMaxLength(255);
            entity.Property(e => e.UnitPrice).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.RefundAmount).HasColumnType("decimal(18, 2)");

            entity.HasOne(d => d.OrderItem).WithMany(p => p.ReturnItems)
                .HasForeignKey(d => d.OrderItemId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ReturnIte__Order__76969D2E");

            entity.HasOne(d => d.ReturnRequest).WithMany(p => p.ReturnItems)
                .HasForeignKey(d => d.ReturnRequestId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ReturnIte__Retur__75A278F5");
        });

        modelBuilder.Entity<ReturnRequest>(entity =>
        {
            entity.HasKey(e => e.ReturnRequestId).HasName("PK__ReturnRe__0CCD2599808D7145");

            entity.HasIndex(e => e.RequestCode, "UQ_ReturnRequests_RequestCode").IsUnique();
            entity.HasIndex(e => new { e.OrderId, e.Status }, "IX_ReturnRequests_OrderId_Status");

            entity.Property(e => e.AdminNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.BankAccountName).HasMaxLength(100);
            entity.Property(e => e.BankAccountNumber).HasMaxLength(50);
            entity.Property(e => e.BankName).HasMaxLength(100);
            entity.Property(e => e.CustomerNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.InspectionNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.Reason).HasColumnType("nvarchar(max)");
            entity.Property(e => e.RefundTransactionNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.RequestCode).HasMaxLength(50);
            entity.Property(e => e.RequestedAmount).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.RequestedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.ApprovedAt).HasColumnType("datetime");
            entity.Property(e => e.RejectedAt).HasColumnType("datetime");
            entity.Property(e => e.ReturnCarrier).HasMaxLength(50);
            entity.Property(e => e.ReturnTrackingCode).HasMaxLength(100);
            entity.Property(e => e.ReturnShipmentNote).HasColumnType("nvarchar(max)");
            entity.Property(e => e.ReturnShippedAt).HasColumnType("datetime");
            entity.Property(e => e.ReturnReceivedAt).HasColumnType("datetime");
            entity.Property(e => e.RefundedAt).HasColumnType("datetime");
            entity.Property(e => e.Status).HasMaxLength(50);

            entity.HasOne(d => d.Order).WithMany(p => p.ReturnRequests)
                .HasForeignKey(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ReturnReq__Order__71D1E811");

            entity.HasOne(d => d.ProcessedByAdmin).WithMany(p => p.ProcessedReturnRequests)
                .HasForeignKey(d => d.ProcessedByAdminId)
                .OnDelete(DeleteBehavior.NoAction)
                .HasConstraintName("FK_ReturnRequests_ProcessedByAdmin");

            entity.HasOne(d => d.User).WithMany(p => p.ReturnRequests)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__ReturnReq__UserI__72C60C4A");
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.ReviewId).HasName("PK__Reviews__74BC79CEEDD680CB");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.Property(e => e.EditCount)
                .HasDefaultValue(0);

            entity.HasOne(d => d.Product).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reviews__Product__01142BA1");

            entity.HasOne(d => d.User).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Reviews__UserId__00200768");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleId).HasName("PK__Roles__8AFACE1AA6950E57");

            entity.HasIndex(e => e.RoleName, "UQ__Roles__8A2B616015CC2BBD").IsUnique();

            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<Shipment>(entity =>
        {
            entity.HasKey(e => e.ShipmentId).HasName("PK__Shipment__5CAD37ED2257823A");

            entity.HasIndex(e => e.OrderId, "UQ__Shipment__C3905BCEA0118E11").IsUnique();

            entity.Property(e => e.DeliveredAt).HasColumnType("datetime");
            entity.Property(e => e.ExpectedDeliveryTime).HasColumnType("datetime");
            entity.Property(e => e.GhnOrderCode).HasMaxLength(100);
            entity.Property(e => e.RawGhnStatus).HasMaxLength(100);
            entity.Property(e => e.ShippedAt).HasColumnType("datetime");
            entity.Property(e => e.ShippingFee).HasColumnType("decimal(18, 2)");
            entity.Property(e => e.ShippingProvider).HasMaxLength(100);
            entity.Property(e => e.Status).HasMaxLength(50);
            entity.Property(e => e.TrackingCode).HasMaxLength(100);

            entity.HasOne(d => d.Order).WithOne(p => p.Shipment)
                .HasForeignKey<Shipment>(d => d.OrderId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Shipments__Order__6E01572D");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserId).HasName("PK__Users__1788CC4CCF0286FA");

            entity.HasIndex(e => e.Email, "UQ__Users__A9D10534CD838107").IsUnique();

            entity.Property(e => e.AvatarUrl).HasMaxLength(255);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.FullName).HasMaxLength(100);
            entity.Property(e => e.Gender).HasMaxLength(20);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.PasswordHash).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.ResetPasswordOtp).HasMaxLength(6);
            entity.Property(e => e.ResetPasswordOtpExpiredAt).HasColumnType("datetime");
            entity.Property(e => e.ResetPasswordOtpLastSentAt).HasColumnType("datetime");
            entity.Property(e => e.ResetPasswordOtpFailedAttempts).HasDefaultValue(0);
            entity.Property(e => e.ResetPasswordToken).HasMaxLength(255);
            entity.Property(e => e.ResetPasswordTokenExpires).HasColumnType("datetime");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Users__RoleId__3D5E1FD2");
        });

        modelBuilder.Entity<UserAddress>(entity =>
        {
            entity.HasKey(e => e.AddressId).HasName("PK__UserAddr__091C2AFB003ECD84");

            entity.Property(e => e.AddressLine).HasMaxLength(255);
            entity.Property(e => e.City).HasMaxLength(100);
            entity.Property(e => e.District).HasMaxLength(100);
            entity.Property(e => e.IsDefault).HasDefaultValue(false);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.ReceiverName).HasMaxLength(100);
            entity.Property(e => e.Ward).HasMaxLength(100);
            entity.Property(e => e.WardCode).HasMaxLength(20);

            entity.HasOne(d => d.User).WithMany(p => p.UserAddresses)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__UserAddre__UserI__412EB0B6");
        });

        modelBuilder.Entity<Wishlist>(entity =>
        {
            entity.HasKey(e => e.WishlistId).HasName("PK__Wishlist__233189EBC573B413");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Product).WithMany(p => p.Wishlists)
                .HasForeignKey(d => d.ProductId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Wishlists__Produ__05D8E0BE");

            entity.HasOne(d => d.Variant).WithMany(p => p.Wishlists)
                .HasForeignKey(d => d.VariantId)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasOne(d => d.User).WithMany(p => p.Wishlists)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK__Wishlists__UserI__04E4BC85");
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.NotificationId);

            entity.ToTable("Notifications");

            entity.Property(e => e.Title).HasMaxLength(200);
            entity.Property(e => e.Message).HasMaxLength(1000);
            entity.Property(e => e.Type).HasMaxLength(100);
            entity.Property(e => e.Role).HasMaxLength(50);
            entity.Property(e => e.ActionUrl).HasMaxLength(500);
            entity.Property(e => e.MetadataJson).HasColumnType("nvarchar(max)");
            entity.Property(e => e.IsRead).HasDefaultValue(false);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.ReadAt).HasColumnType("datetime2");

            entity.HasOne(d => d.User).WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<NotificationRecipient>(entity =>
        {
            entity.HasKey(e => e.NotificationRecipientId);

            entity.ToTable("NotificationRecipients");

            entity.HasIndex(e => new { e.NotificationId, e.UserId }, "UX_NotificationRecipients_Notification_User")
                .IsUnique();
            entity.HasIndex(e => new { e.UserId, e.IsRead }, "IX_NotificationRecipients_UserId_IsRead");
            entity.HasIndex(e => e.CreatedAt, "IX_NotificationRecipients_CreatedAt");

            entity.Property(e => e.IsRead).HasDefaultValue(false);
            entity.Property(e => e.CreatedAt).HasColumnType("datetime2");
            entity.Property(e => e.ReadAt).HasColumnType("datetime2");

            entity.HasOne(d => d.Notification).WithMany(p => p.Recipients)
                .HasForeignKey(d => d.NotificationId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.User).WithMany(p => p.NotificationRecipients)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
