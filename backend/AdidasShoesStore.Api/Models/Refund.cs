using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class Refund
{
    public int RefundId { get; set; }

    public int ReturnRequestId { get; set; }

    public int OrderId { get; set; }

    public decimal Amount { get; set; }

    public string Status { get; set; } = null!;

    public string? PaymentMethod { get; set; }

    public string? TransactionCode { get; set; }

    public DateTime? RefundedAt { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual ReturnRequest ReturnRequest { get; set; } = null!;
}
