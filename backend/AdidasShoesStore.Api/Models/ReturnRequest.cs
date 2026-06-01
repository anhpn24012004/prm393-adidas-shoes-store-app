using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class ReturnRequest
{
    public int ReturnRequestId { get; set; }

    public int OrderId { get; set; }

    public int UserId { get; set; }

    public string Reason { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateTime? RequestedAt { get; set; }

    public string? AdminNote { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual Refund? Refund { get; set; }

    public virtual ICollection<ReturnItem> ReturnItems { get; set; } = new List<ReturnItem>();

    public virtual User User { get; set; } = null!;
}
