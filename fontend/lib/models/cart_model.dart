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
        .map((item) => CartItemModel.fromJson(item))
        .toList();

    return CartModel(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      cartItems: items,
    );
  }
}
