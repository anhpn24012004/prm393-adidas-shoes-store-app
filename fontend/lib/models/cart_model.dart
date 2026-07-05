import 'cart_item_model.dart';

class CartModel {
  final int cartId;
  final int userId;
  final int totalItems;
  final List<CartItemModel> cartItems;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.totalItems,
    required this.cartItems,
  });

  double get totalAmount {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items = (json['cartItems'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .toList();

    return CartModel(
      cartId: _parseInt(json['cartId']),
      userId: _parseInt(json['userId']),
      totalItems: _parseInt(json['totalItems']),
      cartItems: items,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
