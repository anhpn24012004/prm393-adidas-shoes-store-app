import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/inventory_realtime_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/notification_bell.dart';
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
  StreamSubscription? _stockChangedSubscription;
  Timer? _stockReloadDebounce;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _categoriesFuture = _categoryService.getCategories();
    _stockChangedSubscription = InventoryRealtimeService
        .instance
        .stockChangedStream
        .listen((_) => _scheduleProductsReload());
    BadgeNotifier.instance.refreshCounts();
  }

  @override
  void dispose() {
    _stockReloadDebounce?.cancel();
    _stockChangedSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
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

  void _scheduleProductsReload() {
    _stockReloadDebounce?.cancel();
    _stockReloadDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(_loadProducts);
    });
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
            height: 54,
            child: AppLoadingState(compact: true),
          );
        }

        if (snapshot.hasError) return const SizedBox.shrink();

        final categories = (snapshot.data ?? [])
            .where((category) => category.productCount > 0)
            .toList();

        if (selectedCategoryId != null &&
            !categories.any(
              (category) => category.categoryId == selectedCategoryId,
            )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || selectedCategoryId == null) return;
            _filterByCategory(null);
          });
        }

        return SizedBox(
          height: 54,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    label: Text(category.categoryName),
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

  int _gridCountForWidth(double width) {
    if (width >= 1100) return 4;
    if (width >= 760) return 3;
    return 2;
  }

  Widget _buildBody() {
    return FutureBuilder<PagedProductResponse>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingState();
        }

        if (snapshot.hasError) {
          return AppErrorState(
            message: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
            onRetry: () => setState(_loadProducts),
          );
        }

        final pagedResult = snapshot.data;
        final products = pagedResult?.items ?? [];
        _totalPages = pagedResult?.totalPages ?? 0;

        if (products.isEmpty) {
          final isDefaultAllView =
              selectedCategoryId == null &&
              (_keyword == null || _keyword!.trim().isEmpty);

          return AppEmptyState(
            icon: Icons.search_off_outlined,
            title: isDefaultAllView
                ? 'Chưa có sản phẩm'
                : 'Không tìm thấy sản phẩm phù hợp.',
            message: isDefaultAllView
                ? 'Sản phẩm sẽ hiển thị tại đây khi cửa hàng cập nhật.'
                : 'Hãy thử từ khóa khác hoặc chọn lại danh mục.',
            action: AppOutlinedButton(
              text: context.tr('all'),
              icon: Icons.refresh,
              fullWidth: false,
              onPressed: () => _filterByCategory(null),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCountForWidth(constraints.maxWidth),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: constraints.maxWidth < 430
                          ? 0.56
                          : 0.62,
                    ),
                    itemBuilder: (context, index) {
                      return AppProductCard(
                        product: products[index],
                        onTap: () => _goToDetail(products[index]),
                      );
                    },
                  );
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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.outlined(
              onPressed: hasPreviousPage
                  ? () => _changePage(_currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Trang $_currentPage / ${totalPages == 0 ? 1 : totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            IconButton.filled(
              onPressed: hasNextPage
                  ? () => _changePage(_currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right, color: Colors.white),
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
        actions: const [
          NotificationBell(),
          CartWishlistBadges(),
          SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                  ),
                ),
              ),
              _buildCategoryFilter(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }
}
