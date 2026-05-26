# Database Design

## Database
SQL Server

---

# Main Tables

## 1. Roles
Store system roles.

### Fields
- RoleId
- RoleName

---

## 2. Users
Store user information.

### Fields
- UserId
- FullName
- Email
- PasswordHash
- Phone
- Gender
- DateOfBirth
- AvatarUrl
- RoleId
- IsActive
- CreatedAt

---

## 3. UserAddresses
Store delivery addresses of users.

### Fields
- AddressId
- UserId
- ReceiverName
- Phone
- AddressLine
- Ward
- District
- City
- IsDefault

---

## 4. Categories
Store product categories.

### Fields
- CategoryId
- CategoryName
- Description

---

## 5. Products
Store main product information.

### Fields
- ProductId
- ProductName
- Description
- BasePrice
- CategoryId
- Brand
- Gender
- Material
- IsActive
- CreatedAt

---

## 6. ProductVariants
Store product variations such as size and color.

### Fields
- VariantId
- ProductId
- Size
- Color
- Price
- StockQuantity
- SKU
- IsActive

---

## 7. ProductImages
Store product images.

### Fields
- ImageId
- ProductId
- ImageUrl
- IsMain

---

## 8. Carts
Store user shopping cart.

### Fields
- CartId
- UserId
- CreatedAt

---

## 9. CartItems
Store products inside shopping cart.

### Fields
- CartItemId
- CartId
- VariantId
- Quantity

---

## 10. Orders
Store customer orders.

### Fields
- OrderId
- UserId
- OrderCode
- TotalAmount
- ShippingFee
- DiscountAmount
- FinalAmount
- Status
- ShippingAddress
- ReceiverName
- ReceiverPhone
- Note
- CreatedAt

---

## 11. OrderItems
Store products inside orders.

### Fields
- OrderItemId
- OrderId
- VariantId
- ProductName
- Size
- Color
- Quantity
- UnitPrice

---

## 12. Payments
Store payment information.

### Fields
- PaymentId
- OrderId
- PaymentMethod
- Amount
- Status
- TransactionCode
- PaidAt

---

## 13. Shipments
Store shipping information.

### Fields
- ShipmentId
- OrderId
- ShippingProvider
- TrackingCode
- Status
- ShippedAt
- DeliveredAt

---

## 14. ReturnRequests
Store return/refund requests.

### Fields
- ReturnRequestId
- OrderId
- UserId
- Reason
- Status
- RequestedAt
- AdminNote

---

## 15. ReturnItems
Store returned products.

### Fields
- ReturnItemId
- ReturnRequestId
- OrderItemId
- Quantity
- Reason

---

## 16. Refunds
Store refund information.

### Fields
- RefundId
- ReturnRequestId
- OrderId
- Amount
- Status
- PaymentMethod
- TransactionCode
- RefundedAt

---

## 17. Reviews
Store customer reviews.

### Fields
- ReviewId
- UserId
- ProductId
- Rating
- Comment
- CreatedAt

---

## 18. Wishlists
Store favorite products.

### Fields
- WishlistId
- UserId
- ProductId
- CreatedAt

---

## 19. AIRecommendationLogs
Store AI recommendation history.

### Fields
- LogId
- UserId
- UserPrompt
- RecommendedProductIds
- RecommendedSize
- CreatedAt

---

# Relationships

- Role 1 - n Users
- User 1 - n UserAddresses
- Category 1 - n Products
- Product 1 - n ProductVariants
- Product 1 - n ProductImages
- User 1 - 1 Cart
- Cart 1 - n CartItems
- ProductVariant 1 - n CartItems
- User 1 - n Orders
- Order 1 - n OrderItems
- ProductVariant 1 - n OrderItems
- Order 1 - 1 Payment
- Order 1 - 1 Shipment
- Order 1 - n ReturnRequests
- ReturnRequest 1 - n ReturnItems
- ReturnRequest 1 - 1 Refund
- User 1 - n Reviews
- Product 1 - n Reviews
- User 1 - n Wishlists
- Product 1 - n Wishlists
- User 1 - n AIRecommendationLogs