using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class ProductVariant
{
    public int VariantId { get; set; }

    public int ProductId { get; set; }

    public string Size { get; set; } = null!;

    public string Color { get; set; } = null!;

    public string? ImageUrl { get; set; }

    public string? OptionValuesJson { get; set; }

    public decimal Price { get; set; }

    public int? StockQuantity { get; set; }

    public string? Sku { get; set; }

    public bool? IsActive { get; set; }

    public virtual ICollection<CartItem> CartItems { get; set; } = new List<CartItem>();

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual ICollection<Wishlist> Wishlists { get; set; } = new List<Wishlist>();

    public virtual Product Product { get; set; } = null!;
}
