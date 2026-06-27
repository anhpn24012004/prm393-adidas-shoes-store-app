using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class ReturnRequest
{
    public int ReturnRequestId { get; set; }

    public int OrderId { get; set; }

    public int UserId { get; set; }

    public string RequestCode { get; set; } = null!;

    public string Reason { get; set; } = null!;

    public string Status { get; set; } = null!;

    public DateTime? RequestedAt { get; set; }

    public string? CustomerNote { get; set; }

    public string? AdminNote { get; set; }

    public string BankName { get; set; } = null!;

    public string BankAccountNumber { get; set; } = null!;

    public string BankAccountName { get; set; } = null!;

    public decimal RequestedAmount { get; set; }

    public DateTime? ApprovedAt { get; set; }

    public DateTime? RejectedAt { get; set; }

    public string? ReturnCarrier { get; set; }

    public string? ReturnTrackingCode { get; set; }

    public string? ReturnShipmentNote { get; set; }

    public DateTime? ReturnShippedAt { get; set; }

    public DateTime? ReturnReceivedAt { get; set; }

    public string? InspectionNote { get; set; }

    public bool? IsRestockable { get; set; }

    public int? RestockQuantity { get; set; }

    public string? RefundTransactionNote { get; set; }

    public DateTime? RefundedAt { get; set; }

    public int? ProcessedByAdminId { get; set; }

    public virtual Order Order { get; set; } = null!;

    public virtual User? ProcessedByAdmin { get; set; }

    public virtual Refund? Refund { get; set; }

    public virtual ICollection<ReturnItem> ReturnItems { get; set; } = new List<ReturnItem>();

    public virtual User User { get; set; } = null!;
}
