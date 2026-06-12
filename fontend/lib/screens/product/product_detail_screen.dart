import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../theme/app_theme.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  final ReviewService _reviewService = ReviewService();

  late Future<ProductDetailModel> _productFuture;
  late Future<List<ReviewResponse>> _reviewsFuture;

  ProductVariantModel? selectedVariant;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
    _reviewsFuture = _reviewService.getReviewsByProductId(widget.productId);
    BadgeNotifier.instance.refreshCounts();
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  String? getMainImage(ProductDetailModel product) {
    if (product.images.isEmpty) return null;

    final mainImages = product.images.where((image) => image.isMain).toList();

    if (mainImages.isNotEmpty) {
      return mainImages.first.imageUrl;
    }

    return product.images.first.imageUrl;
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 390,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 64)),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 390,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 390,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 64)),
        );
      },
    );
  }

  Widget _buildVariantSelector(ProductDetailModel product) {
    if (product.variants.isEmpty) {
      return Text(context.tr('noVariants'));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.variants.map((variant) {
        final isSelected = selectedVariant?.variantId == variant.variantId;

        return ChoiceChip(
          selected: isSelected,
          label: Text('${variant.size} - ${variant.color}'),
          onSelected: variant.stockQuantity <= 0
              ? null
              : (_) {
                  setState(() {
                    selectedVariant = variant;
                  });
                },
        );
      }).toList(),
    );
  }

  Future<void> _addToCart() async {
    if (selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectSizeColorPrompt'))),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final totalItems = await _cartService.addToCart(
        userId: AppConfig.currentUserId,
        variantId: selectedVariant!.variantId,
        quantity: 1,
      );

      BadgeNotifier.instance.setCartCount(totalItems);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('addedToCart')} ($totalItems ${context.tr('items')})',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addToWishlist() async {
    try {
      final totalItems = await _wishlistService.addWishlist(
        userId: AppConfig.currentUserId,
        productId: widget.productId,
      );

      BadgeNotifier.instance.setWishlistCount(totalItems);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('addedToWishlist')} '
            '($totalItems ${context.tr('items')})',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    // Sau này nối Cart API:
    // POST /api/cart/items
    // body: { "variantId": selectedVariant!.variantId, "quantity": 1 }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductDetailModel>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('${context.tr('error')}: ${snapshot.error}'),
              ),
            ),
          );
        }

        final product = snapshot.data!;
        final imageUrl = getMainImage(product);
        final displayPrice = selectedVariant?.price ?? product.basePrice;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('productDetails').toUpperCase()),
            actions: const [CartWishlistBadges()],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.surface,
                  child: _buildImage(imageUrl),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.productName,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: _addToWishlist,
                        icon: const Icon(Icons.favorite_border),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('customerReviews').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final created = await Navigator.pushNamed(
                            context,
                            '/create-review',
                            arguments: widget.productId,
                          );
                          if (created == true && mounted) {
                            setState(() {
                              _reviewsFuture = _reviewService
                                  .getReviewsByProductId(widget.productId);
                            });
                          }
                        },
                        child: Text(context.tr('writeReview').toUpperCase()),
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<ReviewResponse>>(
                  future: _reviewsFuture,
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: LinearProgressIndicator(),
                      );
                    }
                    final reviews = reviewSnapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Text(
                          context.tr('noReviews'),
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      );
                    }
                    return Column(
                      children: reviews.take(5).map((review) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          title: Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < review.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 17,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ),
                          subtitle: Text(review.comment ?? ''),
                        );
                      }).toList(),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    formatPrice(displayPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoTag(product.categoryName ?? 'Originals'),
                      _InfoTag(product.gender ?? 'Unisex'),
                      _InfoTag(product.material ?? 'Performance material'),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    context.tr('selectSizeColor').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildVariantSelector(product),
                ),

                if (selectedVariant != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      '${context.tr('stock')}: ${selectedVariant!.stockQuantity}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    context.tr('productDescription').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(
                    product.description ?? context.tr('noDescription'),
                    style: const TextStyle(color: AppColors.muted, height: 1.6),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addToCart,
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        (_isLoading
                                ? context.tr('adding')
                                : context.tr('addToBag'))
                            .toUpperCase(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;

  const _InfoTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      color: AppColors.surface,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
