import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/wishlist_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/auth_storage.dart';
import '../../services/wishlist_service.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/product_rating.dart';
import '../product/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  final AuthStorage _authStorage = AuthStorage();

  Future<List<WishlistModel>>? _wishlistFuture;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadWishlist();
  }

  Future<void> _checkAuthAndLoadWishlist() async {
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
      _wishlistFuture = _wishlistService.getWishlist();
    });
  }

  void _loadWishlist() {
    setState(() {
      _wishlistFuture = _wishlistService.getWishlist();
    });
  }

  String _formatPrice(double price) {
    return formatVnd(price);
  }

  Future<void> _removeItem(WishlistModel item) async {
    try {
      final totalItems = await _wishlistService.deleteWishlist(item.wishlistId);
      BadgeNotifier.instance.setWishlistCount(totalItems);
      _loadWishlist();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _clearWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('clearWishlist')),
        content: Text(context.tr('clearWishlistQuestion')),
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
      final totalItems = await _wishlistService.clearWishlist();
      BadgeNotifier.instance.setWishlistCount(totalItems);
      _loadWishlist();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _openProductDetail(WishlistModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: item.productId),
      ),
    );
  }

  Widget _buildItemImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  Widget _buildWishlistItem(WishlistModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _openProductDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildItemImage(item.imageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.basePrice),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ProductRating(
                      averageRating: item.averageRating,
                      reviewCount: item.reviewCount,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(item),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistFuture = _wishlistFuture;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('myWishlist')),
        actions: const [CartWishlistBadges()],
      ),
      body: _isCheckingAuth || wishlistFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<WishlistModel>>(
              future: wishlistFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${context.tr('error')}: ${snapshot.error}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadWishlist,
                            child: Text(context.tr('retry')),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final items = snapshot.data ?? [];

                if (items.isEmpty) {
                  return Center(child: Text(context.tr('wishlistEmpty')));
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _buildWishlistItem(items[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _clearWishlist,
                          child: Text(context.tr('clearWishlist')),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
