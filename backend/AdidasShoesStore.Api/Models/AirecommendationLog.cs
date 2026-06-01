using System;
using System.Collections.Generic;

namespace AdidasShoesStore.Api.Models;

public partial class AirecommendationLog
{
    public int LogId { get; set; }

    public int? UserId { get; set; }

    public string UserPrompt { get; set; } = null!;

    public string? RecommendedProductIds { get; set; }

    public string? RecommendedSize { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual User? User { get; set; }
}
