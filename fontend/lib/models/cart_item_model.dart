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
      cartItemId: _parseInt(json['cartItemId']),
      variantId: _parseInt(json['variantId']),
      productId: _parseInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      quantity: _parseInt(json['quantity']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
