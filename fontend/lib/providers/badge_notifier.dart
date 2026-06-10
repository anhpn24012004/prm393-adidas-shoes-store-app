import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class BadgeNotifier extends ChangeNotifier {
  BadgeNotifier._();

  static final BadgeNotifier instance = BadgeNotifier._();

  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  int cartCount = 0;
  int wishlistCount = 0;

  void setCartCount(int count) {
    if (cartCount == count) return;
    cartCount = count;
    notifyListeners();
  }

  void setWishlistCount(int count) {
    if (wishlistCount == count) return;
    wishlistCount = count;
    notifyListeners();
  }

  Future<void> refreshCounts({int? userId}) async {
    final id = userId ?? AppConfig.currentUserId;

    try {
      final results = await Future.wait([
        _cartService.getCartCount(id),
        _wishlistService.getWishlistCount(id),
      ]);

      cartCount = results[0];
      wishlistCount = results[1];
      notifyListeners();
    } catch (_) {
      // Keep current badge values if the API is unavailable.
    }
  }
}
