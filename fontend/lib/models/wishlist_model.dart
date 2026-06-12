class WishlistModel {
  final int wishlistId;
  final int productId;
  final String productName;
  final double basePrice;
  final String? imageUrl;
  final DateTime? createdAt;

  WishlistModel({
    required this.wishlistId,
    required this.productId,
    required this.productName,
    required this.basePrice,
    this.imageUrl,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      wishlistId: json['wishlistId'],
      productId: json['productId'],
      productName: json['productName'] ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
