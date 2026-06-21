import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/product_rating.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/store_brand.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  late Future<PagedProductResponse> _productsFuture;
  late Future<List<CategoryModel>> _categoriesFuture;

  int _currentPage = 1;
  final int _pageSize = 8;
  int _totalPages = 0;
  String? _keyword;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _categoriesFuture = _categoryService.getCategories();
    BadgeNotifier.instance.refreshCounts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    return formatVnd(price);
  }

  void _searchProduct() {
    final keyword = _searchController.text.trim();

    setState(() {
      _currentPage = 1;
      _keyword = keyword.isEmpty ? null : keyword;
      selectedCategoryId = null;
      _loadProducts();
    });
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _currentPage = 1;
      _keyword = null;
      selectedCategoryId = categoryId;
      _searchController.clear();
      _loadProducts();
    });
  }

  void _loadProducts() {
    _productsFuture = _productService.getProducts(
      pageNumber: _currentPage,
      pageSize: _pageSize,
      keyword: _keyword,
      categoryId: selectedCategoryId,
    );
  }

  void _changePage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
      _loadProducts();
    });
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.productId),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data ?? [];

        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(context.tr('all')),
                  selected: selectedCategoryId == null,
                  onSelected: (_) => _filterByCategory(null),
                ),
              ),
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '${category.categoryName} (${category.productCount})',
                    ),
                    selected: selectedCategoryId == category.categoryId,
                    onSelected: (_) => _filterByCategory(category.categoryId),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 48)),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image, size: 48)),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return InkWell(
      onTap: () => _goToDetail(product),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: AppColors.surface,
                    child: _buildProductImage(product.mainImageUrl),
                  ),
                  const Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.favorite_border, size: 19),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                product.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              product.categoryName ?? 'Originals',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ProductRating(
              averageRating: product.averageRating,
              reviewCount: product.reviewCount,
            ),
            const SizedBox(height: 5),
            Text(
              formatPrice(product.basePrice),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<PagedProductResponse>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${context.tr('error')}: ${snapshot.error}'),
            ),
          );
        }

        final pagedResult = snapshot.data;
        final products = pagedResult?.items ?? [];
        _totalPages = pagedResult?.totalPages ?? 0;

        if (products.isEmpty) {
          return Center(child: Text(context.tr('noProductsFound')));
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 700
                      ? 4
                      : 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.64,
                ),
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              ),
            ),
            _buildPagination(pagedResult),
          ],
        );
      },
    );
  }

  Widget _buildPagination(PagedProductResponse? pagedResult) {
    final totalPages = pagedResult?.totalPages ?? _totalPages;
    final hasPreviousPage = pagedResult?.hasPreviousPage ?? _currentPage > 1;
    final hasNextPage =
        pagedResult?.hasNextPage ??
        (totalPages > 0 && _currentPage < totalPages);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: hasPreviousPage
                  ? () => _changePage(_currentPage - 1)
                  : null,
              child: const Text('Previous'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Page $_currentPage / ${totalPages == 0 ? 1 : totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            OutlinedButton(
              onPressed: hasNextPage
                  ? () => _changePage(_currentPage + 1)
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StoreBrand(size: 27),
        actions: [const CartWishlistBadges(), const SizedBox(width: 4)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _searchProduct(),
              decoration: InputDecoration(
                hintText: context.tr('searchHint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _searchProduct,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          _buildCategoryFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
