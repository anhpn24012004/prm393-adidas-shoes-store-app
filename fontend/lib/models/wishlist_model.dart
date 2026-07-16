class WishlistModel {
  final int wishlistId;
  final int productId;
  final String productName;
  final double basePrice;
  final String? imageUrl;
  final double averageRating;
  final int reviewCount;
  final DateTime? createdAt;

  WishlistModel({
    required this.wishlistId,
    required this.productId,
    required this.productName,
    required this.basePrice,
    this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      wishlistId: _parseInt(json['wishlistId']),
      productId: _parseInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
