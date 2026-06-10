import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../providers/badge_notifier.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/cart_wishlist_badges.dart';

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

  late Future<ProductDetailModel> _productFuture;

  ProductVariantModel? selectedVariant;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
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
        height: 280,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 64)),
      );
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 280,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 280,
          width: double.infinity,
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 64)),
        );
      },
    );
  }

  Widget _buildVariantSelector(ProductDetailModel product) {
    if (product.variants.isEmpty) {
      return const Text('No variants available');
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
        const SnackBar(content: Text('Please select size and color')),
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
<<<<<<< HEAD
        SnackBar(
          content: Text('Added to cart ($totalItems items)'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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
          content: Text('Added to wishlist ($totalItems items)'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
=======
        const SnackBar(content: Text('This variant is out of stock')),
      );
      return;
    }

    // Sau này nối Cart API:
    // POST /api/cart/items
    // body: { "variantId": selectedVariant!.variantId, "quantity": 1 }
>>>>>>> origin/develop
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
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        final product = snapshot.data!;
        final imageUrl = getMainImage(product);
        final displayPrice = selectedVariant?.price ?? product.basePrice;

        return Scaffold(
<<<<<<< HEAD
          appBar: AppBar(
            title: Text(product.productName),
            actions: const [
              CartWishlistBadges(),
            ],
          ),
=======
          appBar: AppBar(title: Text(product.productName)),
>>>>>>> origin/develop
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(imageUrl),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    formatPrice(displayPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Category: ${product.categoryName ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Brand: ${product.brand ?? 'Adidas'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Gender: ${product.gender ?? 'N/A'}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Material: ${product.material ?? 'N/A'}'),
                ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Select Size & Color',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildVariantSelector(product),
                ),

                if (selectedVariant != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Stock: ${selectedVariant!.stockQuantity}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),

                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(product.description ?? 'No description'),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _addToWishlist,
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Wishlist'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _addToCart,
                            icon: const Icon(Icons.shopping_cart),
                            label: Text(
                              _isLoading ? 'Adding...' : 'Add To Cart',
                            ),
                          ),
                        ),
                      ),
                    ],
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
