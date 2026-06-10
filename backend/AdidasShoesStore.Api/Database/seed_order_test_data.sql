USE AdidasShoesStore;
GO

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Customer')
    BEGIN
        INSERT INTO Roles (RoleName)
        VALUES (N'Customer');
    END;

    IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Admin')
    BEGIN
        INSERT INTO Roles (RoleName)
        VALUES (N'Admin');
    END;

    DECLARE @CustomerRoleId INT = (
        SELECT RoleId
        FROM Roles
        WHERE RoleName = N'Customer'
    );

    DECLARE @AdminRoleId INT = (
        SELECT RoleId
        FROM Roles
        WHERE RoleName = N'Admin'
    );

    IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = N'order.customer@adidas.test')
    BEGIN
        INSERT INTO Users (
            FullName,
            Email,
            PasswordHash,
            Phone,
            Gender,
            DateOfBirth,
            RoleId,
            IsActive
        )
        VALUES (
            N'Order Test Customer',
            N'order.customer@adidas.test',
            N'123456',
            N'0901234567',
            N'Male',
            '1998-05-20',
            @CustomerRoleId,
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE Email = N'order.admin@adidas.test')
    BEGIN
        INSERT INTO Users (
            FullName,
            Email,
            PasswordHash,
            Phone,
            Gender,
            RoleId,
            IsActive
        )
        VALUES (
            N'Order Test Admin',
            N'order.admin@adidas.test',
            N'123456',
            N'0907654321',
            N'Female',
            @AdminRoleId,
            1
        );
    END;

    DECLARE @CustomerUserId INT = (
        SELECT UserId
        FROM Users
        WHERE Email = N'order.customer@adidas.test'
    );

    IF NOT EXISTS (
        SELECT 1
        FROM UserAddresses
        WHERE UserId = @CustomerUserId
          AND AddressLine = N'123 Nguyen Trai Street'
          AND City = N'Ho Chi Minh City'
    )
    BEGIN
        INSERT INTO UserAddresses (
            UserId,
            ReceiverName,
            Phone,
            AddressLine,
            Ward,
            District,
            City,
            IsDefault
        )
        VALUES (
            @CustomerUserId,
            N'Order Test Customer',
            N'0901234567',
            N'123 Nguyen Trai Street',
            N'Ben Thanh Ward',
            N'District 1',
            N'Ho Chi Minh City',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryName = N'Running Shoes')
    BEGIN
        INSERT INTO Categories (CategoryName, Description)
        VALUES (N'Running Shoes', N'Performance Adidas running shoes for daily training');
    END;

    IF NOT EXISTS (SELECT 1 FROM Categories WHERE CategoryName = N'Lifestyle Shoes')
    BEGIN
        INSERT INTO Categories (CategoryName, Description)
        VALUES (N'Lifestyle Shoes', N'Classic Adidas sneakers for everyday wear');
    END;

    DECLARE @RunningCategoryId INT = (
        SELECT CategoryId
        FROM Categories
        WHERE CategoryName = N'Running Shoes'
    );

    DECLARE @LifestyleCategoryId INT = (
        SELECT CategoryId
        FROM Categories
        WHERE CategoryName = N'Lifestyle Shoes'
    );

    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Adidas Ultraboost Light')
    BEGIN
        INSERT INTO Products (
            ProductName,
            Description,
            BasePrice,
            CategoryId,
            Brand,
            Gender,
            Material,
            IsActive
        )
        VALUES (
            N'Adidas Ultraboost Light',
            N'Lightweight running shoe with responsive Boost cushioning.',
            4200000,
            @RunningCategoryId,
            N'Adidas',
            N'Unisex',
            N'Primeknit textile upper',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductName = N'Adidas Samba OG')
    BEGIN
        INSERT INTO Products (
            ProductName,
            Description,
            BasePrice,
            CategoryId,
            Brand,
            Gender,
            Material,
            IsActive
        )
        VALUES (
            N'Adidas Samba OG',
            N'Iconic low-profile lifestyle sneaker with leather upper.',
            2700000,
            @LifestyleCategoryId,
            N'Adidas',
            N'Unisex',
            N'Leather and suede',
            1
        );
    END;

    DECLARE @UltraboostProductId INT = (
        SELECT ProductId
        FROM Products
        WHERE ProductName = N'Adidas Ultraboost Light'
    );

    DECLARE @SambaProductId INT = (
        SELECT ProductId
        FROM Products
        WHERE ProductName = N'Adidas Samba OG'
    );

    IF NOT EXISTS (SELECT 1 FROM ProductVariants WHERE SKU = N'UB-LIGHT-BLK-42')
    BEGIN
        INSERT INTO ProductVariants (
            ProductId,
            Size,
            Color,
            Price,
            StockQuantity,
            SKU,
            IsActive
        )
        VALUES (
            @UltraboostProductId,
            N'42',
            N'Core Black',
            4200000,
            20,
            N'UB-LIGHT-BLK-42',
            1
        );
    END
    ELSE
    BEGIN
        UPDATE ProductVariants
        SET StockQuantity = CASE
                WHEN StockQuantity IS NULL OR StockQuantity < 20 THEN 20
                ELSE StockQuantity
            END,
            IsActive = 1
        WHERE SKU = N'UB-LIGHT-BLK-42';
    END;

    IF NOT EXISTS (SELECT 1 FROM ProductVariants WHERE SKU = N'UB-LIGHT-WHT-41')
    BEGIN
        INSERT INTO ProductVariants (
            ProductId,
            Size,
            Color,
            Price,
            StockQuantity,
            SKU,
            IsActive
        )
        VALUES (
            @UltraboostProductId,
            N'41',
            N'Cloud White',
            4200000,
            15,
            N'UB-LIGHT-WHT-41',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM ProductVariants WHERE SKU = N'SAMBA-OG-WHT-40')
    BEGIN
        INSERT INTO ProductVariants (
            ProductId,
            Size,
            Color,
            Price,
            StockQuantity,
            SKU,
            IsActive
        )
        VALUES (
            @SambaProductId,
            N'40',
            N'Cloud White / Core Black',
            2700000,
            18,
            N'SAMBA-OG-WHT-40',
            1
        );
    END;

    IF NOT EXISTS (SELECT 1 FROM Carts WHERE UserId = @CustomerUserId)
    BEGIN
        INSERT INTO Carts (UserId)
        VALUES (@CustomerUserId);
    END;

    DECLARE @CartId INT = (
        SELECT CartId
        FROM Carts
        WHERE UserId = @CustomerUserId
    );

    DECLARE @CartVariantId INT = (
        SELECT VariantId
        FROM ProductVariants
        WHERE SKU = N'UB-LIGHT-BLK-42'
    );

    IF NOT EXISTS (
        SELECT 1
        FROM CartItems
        WHERE CartId = @CartId
          AND VariantId = @CartVariantId
    )
    BEGIN
        INSERT INTO CartItems (
            CartId,
            VariantId,
            Quantity
        )
        VALUES (
            @CartId,
            @CartVariantId,
            2
        );
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;

    THROW;
END CATCH;
GO
