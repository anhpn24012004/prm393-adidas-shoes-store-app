using AdidasShoesStore.Api.Data;
using AdidasShoesStore.Api.DTOs.Order;
using AdidasShoesStore.Api.Models;
using AdidasShoesStore.Api.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AdidasShoesStore.Api.Services.Implementations
{
    public class OrderService : IOrderService
    {
        private const decimal ShippingFee = 30000m;
        private const decimal DiscountAmount = 0m;

        private readonly AdidasShoesStoreContext _context;

        public OrderService(
            AdidasShoesStoreContext context)
        {
            _context = context;
        }

        public async Task<OrderServiceResult<OrderDetailDto>> CreateOrderAsync(
            int userId,
            CreateOrderDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.PaymentMethod))
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Payment method is required");
            }

            var address = await _context.UserAddresses
                .AsNoTracking()
                .FirstOrDefaultAsync(a =>
                    a.AddressId == dto.AddressId &&
                    a.UserId == userId);

            if (address == null)
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Address not found");
            }

            var cart = await _context.Carts
                .Include(c => c.CartItems)
                    .ThenInclude(i => i.Variant)
                        .ThenInclude(v => v.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null || !cart.CartItems.Any())
            {
                return OrderServiceResult<OrderDetailDto>.Fail("Cart is empty");
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var totalAmount = cart.CartItems.Sum(i => i.Variant.Price * i.Quantity);
            var finalAmount = totalAmount + ShippingFee - DiscountAmount;
            var createdAt = DateTime.Now;

            var order = new Order
            {
                UserId = userId,
                OrderCode = GenerateOrderCode(),
                TotalAmount = totalAmount,
                ShippingFee = ShippingFee,
                DiscountAmount = DiscountAmount,
                FinalAmount = finalAmount,
                Status = "PendingPayment",
                ShippingAddress = BuildShippingAddress(address),
                ReceiverName = address.ReceiverName,
                ReceiverPhone = address.Phone,
                Note = dto.Note,
                CreatedAt = createdAt,
                Payment = new Payment
                {
                    PaymentMethod = dto.PaymentMethod.Trim(),
                    Amount = finalAmount,
                    Status = "Pending"
                }
            };

            foreach (var item in cart.CartItems)
            {
                order.OrderItems.Add(new OrderItem
                {
                    VariantId = item.VariantId,
                    ProductName = item.Variant.Product.ProductName,
                    Size = item.Variant.Size,
                    Color = item.Variant.Color,
                    Quantity = item.Quantity,
                    UnitPrice = item.Variant.Price
                });
            }

            _context.Orders.Add(order);
            _context.CartItems.RemoveRange(cart.CartItems);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var orderDetail = await GetOrderDetailAsync(userId, order.OrderId);

            return OrderServiceResult<OrderDetailDto>.Ok(orderDetail!);
        }

        public async Task<List<OrderListDto>> GetMyOrdersAsync(int userId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .Select(o => new OrderListDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    TotalAmount = o.TotalAmount,
                    ShippingFee = o.ShippingFee ?? 0m,
                    DiscountAmount = o.DiscountAmount ?? 0m,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    CreatedAt = o.CreatedAt
                })
                .ToListAsync();
        }

        public async Task<OrderDetailDto?> GetOrderDetailAsync(
            int userId,
            int orderId)
        {
            return await _context.Orders
                .AsNoTracking()
                .Where(o =>
                    o.OrderId == orderId &&
                    o.UserId == userId)
                .Select(o => new OrderDetailDto
                {
                    OrderId = o.OrderId,
                    OrderCode = o.OrderCode,
                    TotalAmount = o.TotalAmount,
                    ShippingFee = o.ShippingFee ?? 0m,
                    DiscountAmount = o.DiscountAmount ?? 0m,
                    FinalAmount = o.FinalAmount,
                    Status = o.Status,
                    ShippingAddress = o.ShippingAddress,
                    ReceiverName = o.ReceiverName,
                    ReceiverPhone = o.ReceiverPhone,
                    Note = o.Note,
                    CreatedAt = o.CreatedAt,
                    PaymentId = o.Payment == null ? null : o.Payment.PaymentId,
                    PaymentMethod = o.Payment == null ? null : o.Payment.PaymentMethod,
                    PaymentAmount = o.Payment == null ? null : o.Payment.Amount,
                    PaymentStatus = o.Payment == null ? null : o.Payment.Status,
                    Items = o.OrderItems.Select(i => new OrderItemDto
                    {
                        OrderItemId = i.OrderItemId,
                        VariantId = i.VariantId,
                        ProductName = i.ProductName,
                        Size = i.Size,
                        Color = i.Color,
                        Quantity = i.Quantity,
                        UnitPrice = i.UnitPrice,
                        Subtotal = i.UnitPrice * i.Quantity
                    }).ToList()
                })
                .FirstOrDefaultAsync();
        }

        private static string BuildShippingAddress(UserAddress address)
        {
            var parts = new[]
            {
                address.AddressLine,
                address.Ward,
                address.District,
                address.City
            };

            return string.Join(", ", parts.Where(p => !string.IsNullOrWhiteSpace(p)));
        }

        private static string GenerateOrderCode()
        {
            return $"ORD{DateTime.Now:yyyyMMddHHmmssfff}{Guid.NewGuid():N}"[..25];
        }
    }
}
