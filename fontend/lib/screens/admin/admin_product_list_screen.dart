import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../models/product_model.dart';
import '../../services/inventory_realtime_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

enum _ProductFilter {
  all,
  active,
  draft,
  missingImage,
  missingVariant,
  outOfStock,
}

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  late Future<PagedProductResponse> _productsFuture;
  int _currentPage = 1;
  final int _pageSize = 10;
  _ProductFilter _filter = _ProductFilter.all;
  String? _keyword;
  StreamSubscription? _stockChangedSubscription;
  Timer? _stockReloadDebounce;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _stockChangedSubscription = InventoryRealtimeService
        .instance.stockChangedStream
        .listen((_) => _scheduleProductsReload());
  }

  @override
  void dispose() {
    _stockReloadDebounce?.cancel();
    _stockChangedSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool? get _statusFilter {
    if (_filter == _ProductFilter.active) return true;
    if (_filter == _ProductFilter.draft) return false;
    return null;
  }

  void _loadProducts() {
    _productsFuture = _productService.getAdminProducts(
      pageNumber: _currentPage,
      pageSize: _pageSize,
      keyword: _keyword,
      isActive: _statusFilter,
    );
  }

  void _scheduleProductsReload() {
    _stockReloadDebounce?.cancel();
    _stockReloadDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(_loadProducts);
    });
  }

  void _search() {
    setState(() {
      _keyword = _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim();
      _currentPage = 1;
      _loadProducts();
    });
  }

  void _setFilter(_ProductFilter filter) {
    setState(() {
      _filter = filter;
      _currentPage = 1;
      _loadProducts();
    });
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    switch (_filter) {
      case _ProductFilter.missingImage:
        return products.where((product) => product.imageCount == 0).toList();
      case _ProductFilter.missingVariant:
        return products
            .where((product) => product.activeVariantCount == 0)
            .toList();
      case _ProductFilter.outOfStock:
        return products.where((product) => product.totalStock <= 0).toList();
      case _ProductFilter.all:
      case _ProductFilter.active:
      case _ProductFilter.draft:
        return products;
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('deleteProduct')),
          content: Text(
            '${context.tr('deleteProductQuestion')} "${product.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('delete')),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await _productService.deleteProduct(product.productId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('productDeleted'))));
      setState(() {
        _currentPage = 1;
        _loadProducts();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${context.tr('error')}: $e')));
    }
  }

  Future<void> _toggleProductStatus(ProductModel product) async {
    if (!product.isActive && !_canPublish(product)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_publishBlockMessage(product))));
      return;
    }

    try {
      if (product.isActive) {
        await _productService.updateProduct(
          productId: product.productId,
          productName: product.productName,
          description: product.description,
          basePrice: product.basePrice,
          categoryId: product.categoryId,
          brand: product.brand,
          gender: product.gender,
          material: product.material,
          isActive: false,
        );
      } else {
        await _productService.publishProduct(product.productId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            product.isActive ? 'Product unpublished' : 'Product published',
          ),
        ),
      );
      setState(_loadProducts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.pushNamed(context, '/admin/products/create');
    if (result == true) {
      setState(() {
        _currentPage = 1;
        _loadProducts();
      });
    }
  }

  Future<void> _goToEdit(ProductModel product) async {
    final result = await Navigator.pushNamed(
      context,
      '/admin/products/edit',
      arguments: ProductRouteArgs(product: product),
    );
    if (result == true) {
      setState(() {
        _currentPage = 1;
        _loadProducts();
      });
    }
  }

  Future<void> _goToVariants(ProductModel product) async {
    await Navigator.pushNamed(
      context,
      '/admin/products/variants',
      arguments: ProductRouteArgs(product: product),
    );
    setState(_loadProducts);
  }

  Future<void> _goToImages(ProductModel product) async {
    await Navigator.pushNamed(
      context,
      '/admin/products/images',
      arguments: ProductRouteArgs(product: product),
    );
    setState(_loadProducts);
  }

  bool _canPublish(ProductModel product) {
    return product.imageCount > 0 &&
        product.activeVariantCount > 0 &&
        product.totalStock > 0;
  }

  String _publishBlockMessage(ProductModel product) {
    final missing = [
      if (product.imageCount == 0) 'at least one image',
      if (product.activeVariantCount == 0) 'at least one active variant',
      if (product.totalStock <= 0) 'stock greater than 0',
    ].join(', ');

    return 'Cannot publish yet: missing $missing.';
  }

  void _changePage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
      _loadProducts();
    });
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
        final products = _filteredProducts(pagedResult?.items ?? []);

        if (products.isEmpty) {
          return const _EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No products found',
            message: 'Try changing your search or filter.',
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(_loadProducts),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      product: product,
                      onEdit: () => _goToEdit(product),
                      onImages: () => _goToImages(product),
                      onVariants: () => _goToVariants(product),
                      onToggle: () => _toggleProductStatus(product),
                      onDelete: () => _deleteProduct(product),
                    );
                  },
                ),
              ),
            ),
            _buildPagination(pagedResult),
          ],
        );
      },
    );
  }

  Widget _buildPagination(PagedProductResponse? pagedResult) {
    final totalPages = pagedResult?.totalPages ?? 0;
    final hasPreviousPage = pagedResult?.hasPreviousPage ?? _currentPage > 1;
    final hasNextPage =
        pagedResult?.hasNextPage ??
        (totalPages > 0 && _currentPage < totalPages);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Product management'),
        actions: [
          IconButton(
            tooltip: context.tr('categoryManagement'),
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.pushNamed(context, '/admin/categories'),
          ),
          IconButton(
            tooltip: context.tr('shipmentManagement'),
            icon: const Icon(Icons.local_shipping_outlined),
            onPressed: () => Navigator.pushNamed(context, '/admin/shipments'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _Header(
                  searchController: _searchController,
                  onSearch: _search,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _FilterBar(selected: _filter, onSelected: _setFilter),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create product',
        onPressed: _goToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const _Header({required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manage product catalog, images, variants and stock.',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onSubmitted: (_) => onSearch(),
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: onSearch,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final _ProductFilter selected;
  final ValueChanged<_ProductFilter> onSelected;

  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = [
      (_ProductFilter.all, 'All'),
      (_ProductFilter.active, 'Published'),
      (_ProductFilter.draft, 'Draft'),
      (_ProductFilter.missingImage, 'Missing image'),
      (_ProductFilter.missingVariant, 'Missing variant'),
      (_ProductFilter.outOfStock, 'Out of stock'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.$2),
              selected: selected == filter.$1,
              onSelected: (_) => onSelected(filter.$1),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onImages;
  final VoidCallback onVariants;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onImages,
    required this.onVariants,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _ProductImage(imageUrl: product.mainImageUrl),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _ProductActionMenu(
                      isActive: product.isActive,
                      onEdit: onEdit,
                      onImages: onImages,
                      onVariants: onVariants,
                      onToggle: onToggle,
                      onDelete: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  product.categoryName ?? 'No category',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusBadge(
                      label: product.isActive ? 'Published' : 'Draft',
                      active: product.isActive,
                    ),
                    if (product.imageCount == 0)
                      const _HealthBadge(label: 'Missing image'),
                    if (product.activeVariantCount == 0)
                      const _HealthBadge(label: 'Missing variant'),
                    if (product.totalStock <= 0)
                      const _HealthBadge(label: 'Out of stock'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      formatVnd(product.basePrice),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Stock: ${product.totalStock}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: 96,
        height: 96,
        color: AppColors.surface,
        child: const Icon(Icons.image_outlined, size: 36),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl!),
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return Container(
          width: 96,
          height: 96,
          color: AppColors.surface,
          child: const Icon(Icons.broken_image_outlined, size: 36),
        );
      },
    );
  }
}

class _ProductActionMenu extends StatelessWidget {
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onImages;
  final VoidCallback onVariants;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ProductActionMenu({
    required this.isActive,
    required this.onEdit,
    required this.onImages,
    required this.onVariants,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Product actions',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'images':
            onImages();
            break;
          case 'variants':
            onVariants();
            break;
          case 'toggle':
            onToggle();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'images', child: Text('Images')),
        const PopupMenuItem(value: 'variants', child: Text('Variants')),
        PopupMenuItem(
          value: 'toggle',
          child: Text(isActive ? 'Unpublish' : 'Publish'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool active;

  const _StatusBadge({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: active ? const Color(0xFFE7F6ED) : AppColors.surface,
      labelStyle: TextStyle(
        color: active ? const Color(0xFF1F7A4D) : AppColors.black,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  final String label;

  const _HealthBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: const Color(0xFFFFF2D8),
      labelStyle: const TextStyle(
        color: Color(0xFF805C00),
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
  }
}
