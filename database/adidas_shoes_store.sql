CREATE DATABASE AdidasShoesStore;
GO

USE AdidasShoesStore;
GO

-- =========================
-- 1. ROLES & USERS
-- =========================

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20),
    Gender NVARCHAR(20),
    DateOfBirth DATE,
    AvatarUrl NVARCHAR(255),
    RoleId INT NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

CREATE TABLE UserAddresses (
    AddressId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ReceiverName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NOT NULL,
    AddressLine NVARCHAR(255) NOT NULL,
    Ward NVARCHAR(100),
    District NVARCHAR(100),
    City NVARCHAR(100),
    IsDefault BIT DEFAULT 0,

    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- =========================
-- 2. PRODUCT MANAGEMENT
-- =========================

CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255)
);

CREATE TABLE Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX),
    BasePrice DECIMAL(18,2) NOT NULL,
    CategoryId INT NOT NULL,
    Brand NVARCHAR(100) DEFAULT 'Adidas',
    Gender NVARCHAR(50),
    Material NVARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);

CREATE TABLE ProductVariants (
    VariantId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    Size NVARCHAR(20) NOT NULL,
    Color NVARCHAR(50) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    SKU NVARCHAR(100) NULL,
    IsActive BIT DEFAULT 1,

    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE UNIQUE INDEX UX_ProductVariants_SKU_NotNull
ON ProductVariants(SKU)
WHERE SKU IS NOT NULL;

CREATE TABLE ProductImages (
    ImageId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    ImageUrl NVARCHAR(255) NOT NULL,
    IsMain BIT DEFAULT 0,

    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- =========================
-- 3. CART
-- =========================

CREATE TABLE Carts (
    CartId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL UNIQUE,
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE CartItems (
    CartItemId INT IDENTITY(1,1) PRIMARY KEY,
    CartId INT NOT NULL,
    VariantId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),

    FOREIGN KEY (CartId) REFERENCES Carts(CartId),
    FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId)
);

-- =========================
-- 4. ORDERS
-- =========================

CREATE TABLE Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    OrderCode NVARCHAR(50) NOT NULL UNIQUE,
    TotalAmount DECIMAL(18,2) NOT NULL,
    ShippingFee DECIMAL(18,2) DEFAULT 0,
    DiscountAmount DECIMAL(18,2) DEFAULT 0,
    FinalAmount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    ShippingAddress NVARCHAR(255) NOT NULL,
    ReceiverName NVARCHAR(100) NOT NULL,
    ReceiverPhone NVARCHAR(20) NOT NULL,
    Note NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE OrderItems (
    OrderItemId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    VariantId INT NOT NULL,
    ProductName NVARCHAR(150) NOT NULL,
    Size NVARCHAR(20) NOT NULL,
    Color NVARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,

    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (VariantId) REFERENCES ProductVariants(VariantId)
);

-- =========================
-- 5. PAYMENTS
-- =========================

CREATE TABLE Payments (
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL UNIQUE,
    PaymentMethod NVARCHAR(50) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    TransactionCode NVARCHAR(100),
    PaidAt DATETIME,

    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- =========================
-- 6. SHIPPING
-- =========================

CREATE TABLE Shipments (
    ShipmentId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL UNIQUE,
    ShippingProvider NVARCHAR(100),
    TrackingCode NVARCHAR(100),
    Status NVARCHAR(50),
    ShippedAt DATETIME,
    DeliveredAt DATETIME,

    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- =========================
-- 7. RETURN & REFUND
-- =========================

CREATE TABLE ReturnRequests (
    ReturnRequestId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    UserId INT NOT NULL,
    Reason NVARCHAR(MAX) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    RequestedAt DATETIME DEFAULT GETDATE(),
    AdminNote NVARCHAR(MAX),

    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE TABLE ReturnItems (
    ReturnItemId INT IDENTITY(1,1) PRIMARY KEY,
    ReturnRequestId INT NOT NULL,
    OrderItemId INT NOT NULL,
    Quantity INT NOT NULL,
    Reason NVARCHAR(255),

    FOREIGN KEY (ReturnRequestId) REFERENCES ReturnRequests(ReturnRequestId),
    FOREIGN KEY (OrderItemId) REFERENCES OrderItems(OrderItemId)
);

CREATE TABLE Refunds (
    RefundId INT IDENTITY(1,1) PRIMARY KEY,
    ReturnRequestId INT NOT NULL UNIQUE,
    OrderId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    PaymentMethod NVARCHAR(50),
    TransactionCode NVARCHAR(100),
    RefundedAt DATETIME,

    FOREIGN KEY (ReturnRequestId) REFERENCES ReturnRequests(ReturnRequestId),
    FOREIGN KEY (OrderId) REFERENCES Orders(OrderId)
);

-- =========================
-- 8. REVIEWS & WISHLIST
-- =========================

CREATE TABLE Reviews (
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE TABLE Wishlists (
    WishlistId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

-- =========================
-- 9. NOTIFICATIONS
-- =========================

CREATE TABLE Notifications (
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NULL,
    Role NVARCHAR(50) NULL,
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    Type NVARCHAR(100) NOT NULL,
    IsRead BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    ReadAt DATETIME2 NULL,
    RelatedOrderId INT NULL,
    RelatedPaymentId INT NULL,
    RelatedShipmentId INT NULL,
    RelatedRefundRequestId INT NULL,
    RelatedReturnRequestId INT NULL,
    RelatedProductId INT NULL,
    ActionUrl NVARCHAR(500) NULL,
    MetadataJson NVARCHAR(MAX) NULL,

    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE INDEX IX_Notifications_UserId ON Notifications(UserId);
CREATE INDEX IX_Notifications_Role ON Notifications(Role);
CREATE INDEX IX_Notifications_CreatedAt ON Notifications(CreatedAt);

CREATE TABLE NotificationRecipients (
    NotificationRecipientId INT IDENTITY(1,1) PRIMARY KEY,
    NotificationId INT NOT NULL,
    UserId INT NOT NULL,
    IsRead BIT NOT NULL DEFAULT 0,
    ReadAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    FOREIGN KEY (NotificationId) REFERENCES Notifications(NotificationId) ON DELETE CASCADE,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

CREATE UNIQUE INDEX UX_NotificationRecipients_Notification_User
ON NotificationRecipients(NotificationId, UserId);

CREATE INDEX IX_NotificationRecipients_UserId_IsRead
ON NotificationRecipients(UserId, IsRead);

CREATE INDEX IX_NotificationRecipients_CreatedAt
ON NotificationRecipients(CreatedAt);

-- =========================
-- 10. AI RECOMMENDATION
-- =========================

CREATE TABLE AIRecommendationLogs (
    LogId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT,
    UserPrompt NVARCHAR(MAX) NOT NULL,
    RecommendedProductIds NVARCHAR(255),
    RecommendedSize NVARCHAR(20),
    CreatedAt DATETIME DEFAULT GETDATE(),

    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- =========================
-- 11. SAMPLE DATA
-- =========================

INSERT INTO Roles (RoleName)
VALUES ('Admin'), ('Customer');

INSERT INTO Categories (CategoryName, Description)
VALUES 
('Running Shoes', 'Adidas running shoes'),
('Lifestyle Shoes', 'Adidas lifestyle shoes'),
('Football Shoes', 'Adidas football shoes');

INSERT INTO Users (FullName, Email, PasswordHash, Phone, RoleId)
VALUES
('Admin User', 'admin@adidas.com', '123456', '0900000000', 1),
('Customer User', 'customer@gmail.com', '123456', '0911111111', 2);
