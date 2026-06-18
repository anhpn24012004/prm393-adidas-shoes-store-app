import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/product_rating.dart';
import '../../theme/app_theme.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../utils/currency_formatter.dart';

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
  final Map<int, Future<List<ProductModel>>> _relatedProductsFutures = {};

  ProductVariantModel? selectedVariant;
  String? _selectedImageUrl;
  String? _selectedColor;
  String? _selectedSize;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
    _reviewsFuture = _reviewService.getReviewsByProductId(widget.productId);
    BadgeNotifier.instance.refreshCounts();
  }

  String formatPrice(double price) {
    return formatVnd(price);
  }

  Future<List<ProductModel>> _getRelatedProducts(ProductDetailModel product) {
    return _relatedProductsFutures.putIfAbsent(product.categoryId, () async {
      final products = await _productService.getProductsByCategory(
        product.categoryId,
      );

      return products
          .where((item) => item.productId != product.productId)
          .take(8)
          .toList();
    });
  }

  String? getMainImage(ProductDetailModel product) {
    if (product.images.isEmpty) return null;

    final mainImages = product.images.where((image) => image.isMain).toList();

    if (mainImages.isNotEmpty) {
      return mainImages.first.imageUrl;
    }

    return product.images.first.imageUrl;
  }

  String? getSelectedImage(ProductDetailModel product) {
    if (product.images.isEmpty) return null;

    final selectedImageUrl = _selectedImageUrl;
    final selectedImageExists =
        selectedImageUrl != null &&
        product.images.any((image) => image.imageUrl == selectedImageUrl);

    if (selectedImageExists) {
      return selectedImageUrl;
    }

    return getMainImage(product);
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
      AppConfig.resolveImageUrl(imageUrl),
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

  Widget _buildImageGallery(ProductDetailModel product) {
    final selectedImageUrl = getSelectedImage(product);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildImage(selectedImageUrl),
          if (product.images.length > 1)
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                itemCount: product.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final image = product.images[index];
                  final isSelected = image.imageUrl == selectedImageUrl;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedImageUrl = image.imageUrl;
                      });
                    },
                    child: Container(
                      width: 68,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.black
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Image.network(
                        AppConfig.resolveImageUrl(image.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 24),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<String> _availableColors(ProductDetailModel product) {
    final colors = product.variants
        .where((variant) => variant.isActive)
        .map((variant) => variant.color)
        .where((color) => color.isNotEmpty)
        .toSet()
        .toList();

    colors.sort();
    return colors;
  }

  List<String> _availableSizes(ProductDetailModel product) {
    final selectedColor = _selectedColor;
    final variants = product.variants.where((variant) {
      return variant.isActive &&
          (selectedColor == null || variant.color == selectedColor);
    });

    final sizes = variants
        .map((variant) => variant.size)
        .where((size) => size.isNotEmpty)
        .toSet()
        .toList();

    sizes.sort((a, b) {
      final first = int.tryParse(a);
      final second = int.tryParse(b);

      if (first != null && second != null) {
        return first.compareTo(second);
      }

      return a.compareTo(b);
    });

    return sizes;
  }

  void _syncSelectedVariant(ProductDetailModel product) {
    final selectedColor = _selectedColor;
    final selectedSize = _selectedSize;

    if (selectedColor == null || selectedSize == null) {
      selectedVariant = null;
      return;
    }

    final matches = product.variants.where((variant) {
      return variant.isActive &&
          variant.color == selectedColor &&
          variant.size == selectedSize;
    }).toList();

    selectedVariant = matches.isEmpty ? null : matches.first;
  }

  void _selectColor(ProductDetailModel product, String color) {
    setState(() {
      _selectedColor = color;

      final sizesForColor = product.variants
          .where((variant) => variant.isActive && variant.color == color)
          .map((variant) => variant.size)
          .toSet();

      if (_selectedSize != null && !sizesForColor.contains(_selectedSize)) {
        _selectedSize = null;
      }

      final matchingImage = product.images.where((image) {
        return image.imageUrl.toLowerCase().contains('/$color.'.toLowerCase());
      }).toList();

      if (matchingImage.isNotEmpty) {
        _selectedImageUrl = matchingImage.first.imageUrl;
      }

      _syncSelectedVariant(product);
    });
  }

  void _selectSize(ProductDetailModel product, String size) {
    setState(() {
      _selectedSize = size;
      _syncSelectedVariant(product);
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _buildColorSelector(ProductDetailModel product) {
    if (product.variants.isEmpty) {
      return Text(context.tr('noVariants'));
    }

    final colors = _availableColors(product);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = _selectedColor == color;

        return ChoiceChip(
          selected: isSelected,
          label: Text(color.toUpperCase()),
          onSelected: (_) => _selectColor(product, color),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelector(ProductDetailModel product) {
    final sizes = _availableSizes(product);

    if (sizes.isEmpty) {
      return Text(context.tr('selectSizeColorPrompt'));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) {
        final matchingVariants = product.variants.where((variant) {
          return variant.isActive &&
              variant.size == size &&
              (_selectedColor == null || variant.color == _selectedColor);
        }).toList();
        final hasStock = matchingVariants.any(
          (variant) => variant.stockQuantity > 0,
        );

        return ChoiceChip(
          selected: _selectedSize == size,
          label: Text(size),
          onSelected: hasStock ? (_) => _selectSize(product, size) : null,
        );
      }).toList(),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            context.tr('customerReviews').toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        FutureBuilder<List<ReviewResponse>>(
          future: _reviewsFuture,
          builder: (context, reviewSnapshot) {
            if (reviewSnapshot.connectionState == ConnectionState.waiting) {
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
      ],
    );
  }

  Widget _buildRelatedProducts(ProductDetailModel product) {
    return FutureBuilder<List<ProductModel>>(
      future: _getRelatedProducts(product),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context.tr('relatedProducts')),
            const SizedBox(height: 14),
            SizedBox(
              height: 270,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final relatedProduct = products[index];

                  return _buildRelatedProductCard(relatedProduct);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedProductCard(ProductModel product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.productId),
          ),
        );
      },
      child: SizedBox(
        width: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.surface,
                child: _buildRelatedProductImage(product.mainImageUrl),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              product.categoryName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 5),
            ProductRating(
              averageRating: product.averageRating,
              reviewCount: product.reviewCount,
            ),
            const SizedBox(height: 5),
            Text(
              formatPrice(product.basePrice),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(child: Icon(Icons.image_outlined, size: 42));
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.broken_image_outlined, size: 42));
      },
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

  Future<void> _buyNow() async {
    if (selectedVariant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectSizeColorPrompt'))),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: {
        'variantId': selectedVariant!.variantId,
        'quantity': 1,
      },
    );
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
                _buildImageGallery(product),

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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    formatPrice(displayPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                _buildSectionTitle(context.tr('productDescription')),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Text(
                    product.description ?? context.tr('noDescription'),
                    style: const TextStyle(color: AppColors.muted, height: 1.6),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                _buildSectionTitle(context.tr('productColor')),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildColorSelector(product),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                _buildSectionTitle(context.tr('productSize')),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildSizeSelector(product),
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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _addToCart,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text(context.tr('addToBag').toUpperCase()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _buyNow,
                          icon: const Icon(Icons.flash_on_outlined),
                          label: Text(
                            (_isLoading
                                    ? context.tr('adding')
                                    : context.tr('buyNow'))
                                .toUpperCase(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Divider(height: 1),
                ),

                _buildReviews(),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: Divider(height: 1),
                ),

                _buildRelatedProducts(product),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
