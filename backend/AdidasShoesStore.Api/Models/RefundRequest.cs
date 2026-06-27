using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class RefundRequest
{
    public int RefundRequestId { get; set; }

    public int OrderId { get; set; }

    public int UserId { get; set; }

    public string RequestCode { get; set; } = null!;

    public string Reason { get; set; } = null!;

    public decimal RequestedAmount { get; set; }

    public string BankName { get; set; } = null!;

    public string BankAccountNumber { get; set; } = null!;

    public string BankAccountName { get; set; } = null!;

    public string? CustomerNote { get; set; }

    public string Status { get; set; } = null!;

    public DateTime? CreatedAt { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public DateTime? RejectedAt { get; set; }

    public DateTime? RefundedAt { get; set; }

    public int? ProcessedByAdminId { get; set; }

    public string? ProofImageUrl { get; set; }

    public string? RefundTransactionNote { get; set; }

    public string? AdminNote { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual User User { get; set; } = null!;

    public virtual User? ProcessedByAdmin { get; set; }
}
