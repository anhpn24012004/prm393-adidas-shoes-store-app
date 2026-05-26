# Database Design

## Database
SQL Server

## Tables

### Roles
- RoleId
- RoleName

### Users
- UserId
- FullName
- Email
- PasswordHash
- Phone
- Address
- RoleId
- CreatedAt

### Categories
- CategoryId
- CategoryName
- Description

### Products
- ProductId
- ProductName
- Description
- Price
- Size
- Color
- StockQuantity
- CategoryId
- CreatedAt

### ProductImages
- ImageId
- ProductId
- ImageUrl

### Carts
- CartId
- UserId
- CreatedAt

### CartItems
- CartItemId
- CartId
- ProductId
- Quantity

### Orders
- OrderId
- UserId
- TotalAmount
- Status
- ShippingAddress
- CreatedAt

### OrderDetails
- OrderDetailId
- OrderId
- ProductId
- Quantity
- UnitPrice

### Payments
- PaymentId
- OrderId
- PaymentMethod
- Amount
- Status
- TransactionCode
- PaidAt

### ReturnRequests
- ReturnRequestId
- OrderId
- UserId
- Reason
- Status
- RequestedAt
- AdminNote

### Refunds
- RefundId
- ReturnRequestId
- OrderId
- Amount
- Status
- RefundedAt
- PaymentMethod
- TransactionCode

## Relationships

- Role 1 - n Users
- Category 1 - n Products
- Product 1 - n ProductImages
- User 1 - 1 Cart
- Cart 1 - n CartItems
- Product 1 - n CartItems
- User 1 - n Orders
- Order 1 - n OrderDetails
- Product 1 - n OrderDetails
- Order 1 - 1 Payment
- Order 1 - n ReturnRequests
- ReturnRequest 1 - 1 Refund