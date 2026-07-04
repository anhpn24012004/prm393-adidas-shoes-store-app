class StockChangedEvent {
  final int productId;
  final int variantId;
  final int stockQuantity;
  final int? totalStock;
  final bool isInStock;
  final DateTime? updatedAt;
  final String? reason;

  const StockChangedEvent({
    required this.productId,
    required this.variantId,
    required this.stockQuantity,
    this.totalStock,
    required this.isInStock,
    this.updatedAt,
    this.reason,
  });

  factory StockChangedEvent.fromJson(Map<String, dynamic> json) {
    return StockChangedEvent(
      productId: json['productId'] ?? 0,
      variantId: json['variantId'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      totalStock: json['totalStock'],
      isInStock: json['isInStock'] ?? false,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
      reason: json['reason'],
    );
  }
}
