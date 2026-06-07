class WishlistModel {
  final int wishlistId;
  final int productId;

  WishlistModel({
    required this.wishlistId,
    required this.productId,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      wishlistId: json['wishlistId'],
      productId: json['productId'],
    );
  }
}