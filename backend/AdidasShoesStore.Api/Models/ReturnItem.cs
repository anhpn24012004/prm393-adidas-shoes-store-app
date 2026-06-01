using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class ReturnItem
{
    public int ReturnItemId { get; set; }

    public int ReturnRequestId { get; set; }

    public int OrderItemId { get; set; }

    public int Quantity { get; set; }

    public string? Reason { get; set; }

    public virtual OrderItem OrderItem { get; set; } = null!;

    public virtual ReturnRequest ReturnRequest { get; set; } = null!;
}
