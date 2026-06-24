using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class Order
{
    public int OrderId { get; set; }

    public int UserId { get; set; }

    public string OrderCode { get; set; } = null!;

    public decimal TotalAmount { get; set; }

    public decimal? ShippingFee { get; set; }

    public decimal? DiscountAmount { get; set; }

    public decimal FinalAmount { get; set; }

    public string Status { get; set; } = null!;

    public string ShippingAddress { get; set; } = null!;

    public int? ToDistrictId { get; set; }

    public string? ToWardCode { get; set; }

    public string? ToProvinceName { get; set; }

    public string? ToDistrictName { get; set; }

    public string? ToWardName { get; set; }

    public string ReceiverName { get; set; } = null!;

    public string ReceiverPhone { get; set; } = null!;

    public string? Note { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();

    public virtual Payment? Payment { get; set; }

    public virtual ICollection<Refund> Refunds { get; set; } = new List<Refund>();

    public virtual ICollection<ReturnRequest> ReturnRequests { get; set; } = new List<ReturnRequest>();

    public virtual Shipment? Shipment { get; set; }

    public virtual User User { get; set; } = null!;
}
