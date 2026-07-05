import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/cart_item_model.dart';
import '../../models/cart_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/auth_storage.dart';
import '../../services/cart_service.dart';
import '../../services/inventory_realtime_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/common_widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final AuthStorage _authStorage = AuthStorage();

  Future<CartModel>? _cartFuture;
  bool _isCheckingAuth = true;
  bool _isUpdating = false;
  final Set<int> _cartVariantIds = {};
  StreamSubscription? _stockChangedSubscription;
  Timer? _stockReloadDebounce;

  @override
  void initState() {
    super.initState();
    _stockChangedSubscription = InventoryRealtimeService
        .instance
        .stockChangedStream
        .listen((event) {
          if (!_cartVariantIds.contains(event.variantId)) return;
          _scheduleCartReload();
        });
    _checkAuthAndLoadCart();
  }

  @override
  void dispose() {
    _stockReloadDebounce?.cancel();
    _stockChangedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadCart() async {
    final token = await _authStorage.getToken();
    final userId = await _authStorage.getUserId();

    if (!mounted) return;

    if (token == null || userId == null || userId <= 0) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    AppConfig.currentUserId = userId;

    setState(() {
      _isCheckingAuth = false;
      _cartFuture = _fetchCartAndTrack(userId);
    });
  }

  void _loadCart() {
    setState(() {
      _cartFuture = _fetchCartAndTrack(AppConfig.currentUserId);
    });
  }

  Future<CartModel> _fetchCartAndTrack(int userId) async {
    final cart = await _cartService.getCart(userId);
    _cartVariantIds
      ..clear()
      ..addAll(cart.cartItems.map((item) => item.variantId));
    return cart;
  }

  void _scheduleCartReload() {
    _stockReloadDebounce?.cancel();
    _stockReloadDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted || _isCheckingAuth || AppConfig.currentUserId <= 0) return;
      _loadCart();
    });
  }

  String _formatPrice(double price) => formatVnd(price);

  Future<void> _updateQuantity(CartItemModel item, int newQuantity) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final totalItems = await _cartService.updateQuantity(
        item.cartItemId,
        newQuantity,
      );

      BadgeNotifier.instance.setCartCount(totalItems);
      _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _removeItem(CartItemModel item) async {
    try {
      final totalItems = await _cartService.deleteItem(item.cartItemId);
      BadgeNotifier.instance.setCartCount(totalItems);
      _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('clearCart')),
        content: Text(context.tr('clearCartQuestion')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('clear')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final totalItems = await _cartService.clearCart(AppConfig.currentUserId);
      BadgeNotifier.instance.setCartCount(totalItems);
      _loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildItemImage(String? imageUrl) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.mdBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AppProductImage(imageUrl: imageUrl, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(item.imageUrl),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size ${item.size} / ${item.color}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 5),
                  Text(_formatPrice(item.price), style: AppTextStyles.price),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateQuantity(item, item.quantity - 1),
                        icon: const Icon(Icons.remove, size: 18),
                      ),
                      Container(
                        width: 34,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: _isUpdating
                            ? null
                            : () => _updateQuantity(item, item.quantity + 1),
                        icon: const Icon(Icons.add, size: 18),
                      ),
                      const Spacer(),
                      Text(
                        _formatPrice(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeItem(item),
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(CartModel cart) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tạm tính',
                style: TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              Text(_formatPrice(cart.totalAmount)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển',
                style: TextStyle(fontSize: 15, color: AppColors.muted),
              ),
              Text('Tính ở bước thanh toán'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('total'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _formatPrice(cart.totalAmount),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  text: context.tr('clearCart'),
                  onPressed: _clearCart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppPrimaryButton(
                  text: context.tr('checkout'),
                  icon: Icons.lock_outline,
                  onPressed: () => Navigator.pushNamed(context, '/checkout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartFuture = _cartFuture;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('myCart')),
        actions: const [CartWishlistBadges()],
      ),
      body: _isCheckingAuth || cartFuture == null
          ? const AppLoadingState()
          : FutureBuilder<CartModel>(
              future: cartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState();
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    message: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
                    onRetry: _loadCart,
                  );
                }

                final cart = snapshot.data;
                if (cart == null) {
                  return AppEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Giỏ hàng của bạn đang trống.',
                    message:
                        'Khám phá sản phẩm và thêm đôi giày phù hợp vào giỏ.',
                    action: AppPrimaryButton(
                      text: context.tr('shop'),
                      icon: Icons.arrow_forward,
                      fullWidth: false,
                      onPressed: () => Navigator.pushNamed(context, '/products'),
                    ),
                  );
                }

                if (cart.cartItems.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Giỏ hàng của bạn đang trống.',
                    message:
                        'Khám phá sản phẩm và thêm đôi giày phù hợp vào giỏ.',
                    action: AppPrimaryButton(
                      text: context.tr('shop'),
                      icon: Icons.arrow_forward,
                      fullWidth: false,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/products'),
                    ),
                  );
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: cart.cartItems.length,
                            itemBuilder: (context, index) {
                              return _buildCartItem(cart.cartItems[index]);
                            },
                          ),
                        ),
                        _buildSummary(cart),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
