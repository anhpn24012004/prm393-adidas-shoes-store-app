class CartItemModel {
  final int cartItemId;
  final int variantId;
  final int quantity;

  CartItemModel({
    required this.cartItemId,
    required this.variantId,
    required this.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cartItemId'],
      variantId: json['variantId'],
      quantity: json['quantity'],
    );
  }
}