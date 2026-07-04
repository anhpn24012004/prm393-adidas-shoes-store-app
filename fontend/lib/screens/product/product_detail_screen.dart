import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/auth_storage.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/product_rating.dart';
import '../../theme/app_theme.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../services/inventory_realtime_service.dart';
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
  final AuthStorage _authStorage = AuthStorage();

  late Future<ProductDetailModel> _productFuture;
  late Future<List<ReviewResponse>> _reviewsFuture;
  final Map<int, Future<List<ProductModel>>> _relatedProductsFutures = {};

  ProductVariantModel? selectedVariant;
  String? _selectedImageUrl;
  String? _selectedColor;
  String? _selectedSize;

  bool _isLoading = false;
  StreamSubscription? _stockChangedSubscription;
  Timer? _stockReloadDebounce;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
    _reviewsFuture = _reviewService.getReviewsByProductId(widget.productId);
    _stockChangedSubscription = InventoryRealtimeService
        .instance
        .stockChangedStream
        .listen((event) {
          if (event.productId != widget.productId) return;
          _scheduleProductReload();
        });
    BadgeNotifier.instance.refreshCounts();
  }

  @override
  void dispose() {
    _stockReloadDebounce?.cancel();
    _stockChangedSubscription?.cancel();
    super.dispose();
  }

  void _scheduleProductReload() {
    _stockReloadDebounce?.cancel();
    _stockReloadDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _productFuture = _productService.getProductById(widget.productId);
      });
    });
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

  String _normalizeImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';

    return url.trim().split('?').first.toLowerCase();
  }

  String _normalizeText(String? value) {
    final input = (value ?? '').trim().toLowerCase();
    if (input.isEmpty) return '';

    const replacements = {
      'đ': 'd',
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
    };

    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }

    return buffer.toString();
  }

  String _normalizeColor(String? color) {
    final normalized = _normalizeText(color);
    if (normalized.isEmpty) return '';

    if (normalized.contains('xanh la') || normalized.contains('green')) {
      return 'green';
    }
    if (normalized.contains('red') || normalized.contains('do')) return 'red';
    if (normalized.contains('black') || normalized.contains('den')) {
      return 'black';
    }
    if (normalized.contains('white') || normalized.contains('trang')) {
      return 'white';
    }
    if (normalized.contains('gray') ||
        normalized.contains('grey') ||
        normalized.contains('xam')) {
      return 'gray';
    }
    if (normalized.contains('blue') || normalized.contains('xanh')) {
      return 'blue';
    }

    return normalized;
  }

  List<String> _imageUrlTokens(String? imageUrl) {
    final normalized = _normalizeText(_normalizeImageUrl(imageUrl));
    return normalized
        .split(RegExp(r'[\/\\\-_ .%]+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  bool _imageUrlMatchesColor(String? imageUrl, String color) {
    final normalizedColor = _normalizeColor(color);
    if (normalizedColor.isEmpty) return false;

    final tokens = _imageUrlTokens(imageUrl);
    if (normalizedColor == 'gray') {
      return tokens.contains('gray') || tokens.contains('grey');
    }

    return tokens.contains(normalizedColor);
  }

  String _detectColorFromImageUrl(String? imageUrl) {
    final tokens = _imageUrlTokens(imageUrl);

    if (tokens.contains('red')) return 'red';
    if (tokens.contains('black')) return 'black';
    if (tokens.contains('white')) return 'white';
    if (tokens.contains('gray') || tokens.contains('grey')) return 'gray';
    if (tokens.contains('blue')) return 'blue';
    if (tokens.contains('green')) return 'green';

    return '';
  }

  List<ProductImageModel> _uniqueGalleryImages(ProductDetailModel product) {
    final galleryImages = <ProductImageModel>[];
    final seenUrls = <String>{};

    void addImage(ProductImageModel image) {
      final normalizedUrl = _normalizeImageUrl(image.imageUrl);
      if (normalizedUrl.isEmpty || !seenUrls.add(normalizedUrl)) return;
      galleryImages.add(image);
    }

    final productImages = [...product.images]
      ..sort((first, second) {
        if (first.isMain != second.isMain) {
          return first.isMain ? -1 : 1;
        }
        return first.imageId.compareTo(second.imageId);
      });

    for (final image in productImages) {
      addImage(image);
    }

    for (final variant in product.variants.where((variant) {
      return variant.isActive &&
          _normalizeImageUrl(variant.imageUrl).isNotEmpty;
    })) {
      addImage(
        ProductImageModel(
          imageId: -variant.variantId,
          imageUrl: variant.imageUrl!.trim(),
          isMain: false,
        ),
      );
    }

    return galleryImages;
  }

  List<ProductImageModel> _galleryImagesForSelectedColor(
    ProductDetailModel product,
  ) {
    final galleryImages = _uniqueGalleryImages(product);
    final normalizedColor = _normalizeColor(_selectedColor);
    if (normalizedColor.isEmpty) return galleryImages;

    final colorImages = galleryImages
        .where(
          (image) => _imageUrlMatchesColor(image.imageUrl, normalizedColor),
        )
        .toList();

    return colorImages.isNotEmpty ? colorImages : galleryImages;
  }

  String? getMainImage(ProductDetailModel product) {
    final galleryImages = _uniqueGalleryImages(product);
    return galleryImages.isEmpty ? null : galleryImages.first.imageUrl;
  }

  String? _resolveImageForColor(ProductDetailModel product, String? color) {
    final normalizedColor = _normalizeColor(color);
    if (normalizedColor.isEmpty) return getMainImage(product);

    final matchedVariant = product.variants.where((variant) {
      return variant.isActive &&
          _normalizeColor(variant.color) == normalizedColor &&
          _normalizeImageUrl(variant.imageUrl).isNotEmpty &&
          _imageUrlMatchesColor(variant.imageUrl, normalizedColor);
    }).toList();

    if (matchedVariant.isNotEmpty) return matchedVariant.first.imageUrl;

    final matchedImage = _uniqueGalleryImages(product).where((image) {
      return _imageUrlMatchesColor(image.imageUrl, normalizedColor);
    }).toList();

    if (matchedImage.isNotEmpty) return matchedImage.first.imageUrl;

    final fallbackVariant = product.variants.where((variant) {
      return variant.isActive &&
          _normalizeColor(variant.color) == normalizedColor &&
          _normalizeImageUrl(variant.imageUrl).isNotEmpty;
    }).toList();

    if (fallbackVariant.isNotEmpty) return fallbackVariant.first.imageUrl;

    return getMainImage(product);
  }

  String? getSelectedImage(ProductDetailModel product) {
    final currentGallery = _galleryImagesForSelectedColor(product);
    final selectedImages = currentGallery.where((image) {
      return _normalizeImageUrl(image.imageUrl) ==
          _normalizeImageUrl(_selectedImageUrl);
    }).toList();
    final selectedImage = selectedImages.isEmpty ? null : selectedImages.first;
    if (selectedImage != null) {
      return selectedImage.imageUrl;
    }

    return _resolveImageForColor(product, _selectedColor) ??
        (currentGallery.isEmpty ? null : currentGallery.first.imageUrl) ??
        getMainImage(product);
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
    final galleryImages = _galleryImagesForSelectedColor(product);
    final selectedImageUrl = getSelectedImage(product);
    final normalizedSelectedImageUrl = _normalizeImageUrl(selectedImageUrl);

    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          _buildImage(selectedImageUrl),
          if (galleryImages.length > 1)
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
                itemCount: galleryImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final image = galleryImages[index];
                  final isSelected =
                      _normalizeImageUrl(image.imageUrl) ==
                      normalizedSelectedImageUrl;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedImageUrl = image.imageUrl;
                        final detectedColor = _detectColorFromImageUrl(
                          image.imageUrl,
                        );
                        if (detectedColor.isNotEmpty &&
                            detectedColor != _normalizeColor(_selectedColor)) {
                          final matchingColor = _availableColors(product)
                              .where(
                                (color) =>
                                    _normalizeColor(color) == detectedColor,
                              )
                              .toList();
                          if (matchingColor.isNotEmpty) {
                            _selectedColor = matchingColor.first;
                            _ensureValidSizeForColor(product);
                            _syncSelectedVariant(product);
                          }
                        }
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
    final colorByKey = <String, String>{};
    for (final variant in product.variants.where((variant) {
      return variant.isActive && variant.color.trim().isNotEmpty;
    })) {
      colorByKey.putIfAbsent(_normalizeColor(variant.color), () {
        return variant.color.trim();
      });
    }

    final colors = colorByKey.values.toList()..sort();
    return colors;
  }

  List<String> _availableSizes(ProductDetailModel product) {
    final selectedColor = _normalizeColor(_selectedColor);
    final variants = product.variants.where((variant) {
      return variant.isActive &&
          (selectedColor.isEmpty ||
              _normalizeColor(variant.color) == selectedColor);
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
    final selectedColor = _normalizeColor(_selectedColor);
    final selectedSize = _selectedSize;

    if (selectedSize == null || selectedColor.isEmpty) {
      selectedVariant = null;
      return;
    }

    final matches = product.variants.where((variant) {
      return variant.isActive &&
          variant.size == selectedSize &&
          _normalizeColor(variant.color) == selectedColor;
    }).toList();

    final inStockMatches = matches
        .where((variant) => variant.stockQuantity > 0)
        .toList();

    selectedVariant = inStockMatches.isNotEmpty
        ? inStockMatches.first
        : matches.isEmpty
        ? null
        : matches.first;
  }

  void _ensureValidSizeForColor(ProductDetailModel product) {
    final selectedColor = _normalizeColor(_selectedColor);
    if (selectedColor.isEmpty) {
      _selectedSize = null;
      return;
    }

    final colorVariants = product.variants.where((variant) {
      return variant.isActive &&
          _normalizeColor(variant.color) == selectedColor;
    }).toList();

    final currentSizeHasStock = colorVariants.any((variant) {
      return variant.size == _selectedSize && variant.stockQuantity > 0;
    });

    if (currentSizeHasStock) return;

    final firstInStock = colorVariants
        .where((variant) => variant.stockQuantity > 0)
        .toList();

    _selectedSize = firstInStock.isNotEmpty ? firstInStock.first.size : null;
  }

  void _ensureInitialSelection(ProductDetailModel product) {
    final activeVariants = product.variants
        .where((variant) => variant.isActive)
        .toList();
    if (activeVariants.isEmpty) return;

    final colorIsValid =
        _selectedColor != null &&
        activeVariants.any((variant) {
          return _normalizeColor(variant.color) ==
              _normalizeColor(_selectedColor);
        });

    if (!colorIsValid) {
      final inStockVariants = activeVariants
          .where((variant) => variant.stockQuantity > 0)
          .toList();
      _selectedColor =
          (inStockVariants.isNotEmpty
                  ? inStockVariants.first
                  : activeVariants.first)
              .color;
    }

    _ensureValidSizeForColor(product);
    _syncSelectedVariant(product);

    final currentImageMatchesColor =
        _selectedImageUrl != null &&
        _imageUrlMatchesColor(
          _selectedImageUrl,
          _normalizeColor(_selectedColor),
        );

    if (!currentImageMatchesColor) {
      _selectedImageUrl = _resolveImageForColor(product, _selectedColor);
    }
  }

  void _selectColor(ProductDetailModel product, String color) {
    setState(() {
      _selectedColor = color;
      _ensureValidSizeForColor(product);
      _selectedImageUrl = _resolveImageForColor(product, color);
      _syncSelectedVariant(product);
    });
  }

  void _selectSize(ProductDetailModel product, String size) {
    setState(() {
      _selectedSize = size;
      _syncSelectedVariant(product);
      _selectedImageUrl = _resolveImageForColor(product, _selectedColor);
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
        final isSelected =
            _normalizeColor(_selectedColor) == _normalizeColor(color);

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
              _normalizeColor(variant.color) == _normalizeColor(_selectedColor);
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
                        index < review.rating ? Icons.star : Icons.star_border,
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

  Future<bool> _requireLogin() async {
    final token = await _authStorage.getToken();
    final userId = await _authStorage.getUserId();

    if (!mounted) return false;

    if (token == null || userId == null || userId <= 0) {
      Navigator.pushNamed(context, '/login');
      return false;
    }

    AppConfig.currentUserId = userId;
    return true;
  }

  ProductVariantModel? _findSelectedPurchasableVariant(
    ProductDetailModel product,
  ) {
    final selectedColor = _normalizeColor(_selectedColor);
    final selectedSize = _selectedSize;

    if (selectedColor.isEmpty || selectedSize == null) {
      return null;
    }

    final matches = product.variants.where((variant) {
      return variant.isActive &&
          variant.stockQuantity > 0 &&
          variant.size == selectedSize &&
          _normalizeColor(variant.color) == selectedColor;
    }).toList();

    return matches.isEmpty ? null : matches.first;
  }

  Future<void> _addToCart(ProductDetailModel product) async {
    if (!await _requireLogin()) return;
    if (!mounted) return;

    final variant = _findSelectedPurchasableVariant(product);

    if (variant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn màu và size còn hàng.')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final totalItems = await _cartService.addToCart(
        userId: AppConfig.currentUserId,
        variantId: variant.variantId,
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
      if (!mounted) return;
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

  Future<void> _buyNow(ProductDetailModel product) async {
    if (!await _requireLogin()) return;
    if (!mounted) return;

    final variant = _findSelectedPurchasableVariant(product);

    if (variant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn màu và size còn hàng.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: {
        'variantId': variant.variantId,
        'quantity': 1,
        'unitPrice': variant.price,
        'productName': product.productName,
        'imageUrl': _resolveImageForColor(product, variant.color),
        'size': variant.size,
        'color': variant.color,
      },
    );
  }

  Future<void> _addToWishlist() async {
    if (!await _requireLogin()) return;
    if (!mounted) return;

    try {
      final totalItems = await _wishlistService.addWishlist(
        productId: widget.productId,
        variantId: selectedVariant?.variantId,
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
      if (!mounted) return;
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
        _ensureInitialSelection(product);
        final displayPrice = selectedVariant?.price ?? product.basePrice;
        final canPurchase =
            selectedVariant != null && selectedVariant!.stockQuantity > 0;

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

                if (_availableColors(product).isNotEmpty) ...[
                  _buildSectionTitle(context.tr('productColor')),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _buildColorSelector(product),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Divider(height: 1),
                  ),
                ],

                _buildSectionTitle(context.tr('productSize')),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _buildSizeSelector(product),
                ),

                if (product.variants.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'Out of stock',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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
                          onPressed: _isLoading || !canPurchase
                              ? null
                              : () => _addToCart(product),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text(context.tr('addToBag').toUpperCase()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading || !canPurchase
                              ? null
                              : () => _buyNow(product),
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
