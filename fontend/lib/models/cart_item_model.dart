class CartItemModel {
  final int cartItemId;
  final int variantId;
  final int productId;
  final String productName;
  final String size;
  final String color;
  final double price;
  final String? imageUrl;
  final int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.size,
    required this.color,
    required this.price,
    this.imageUrl,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cartItemId'],
      variantId: json['variantId'],
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl'],
      quantity: json['quantity'] ?? 0,
    );
  }
}
