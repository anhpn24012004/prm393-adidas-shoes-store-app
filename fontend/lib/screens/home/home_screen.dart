import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/category_service.dart';
import '../../services/inventory_realtime_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/store_brand.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _productService = ProductService();
  final _categoryService = CategoryService();
  late Future<List<ProductModel>> _products;
  late final Future<List<CategoryModel>> _categories;
  StreamSubscription? _stockChangedSubscription;
  Timer? _stockReloadDebounce;

  @override
  void initState() {
    super.initState();
    _products = _productService.getProductList();
    _categories = _categoryService.getCategories();
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
    super.dispose();
  }

  void _scheduleProductsReload() {
    _stockReloadDebounce?.cancel();
    _stockReloadDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _products = _productService.getProductList();
      });
    });
  }

  void _openProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StoreBrand(),
        actions: const [
          NotificationBell(),
          CartWishlistBadges(),
          SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero()),
              SliverToBoxAdapter(child: _buildCategories()),
              SliverToBoxAdapter(child: _buildTrending()),
              const SliverToBoxAdapter(child: _MemberBanner()),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) Navigator.pushNamed(context, '/products');
          if (index == 2) Navigator.pushNamed(context, '/ai-assistant');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home, color: Colors.white),
            label: context.tr('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            label: context.tr('shop'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            label: context.tr('aiStylist'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          padding: EdgeInsets.all(compact ? 22 : 30),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: AppRadius.lgBorder,
            boxShadow: AppShadows.floating,
          ),
          child: compact
              ? const _HeroCopy(compact: true)
              : const Row(
                  children: [
                    Expanded(child: _HeroCopy(compact: false)),
                    SizedBox(width: 24),
                    Expanded(child: _HeroVisual()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppSectionTitle(
              title: context.tr('shopBySport'),
              actionLabel: context.tr('viewAll'),
              onAction: () => Navigator.pushNamed(context, '/categories'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 106,
            child: FutureBuilder<List<CategoryModel>>(
              future: _categories,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(compact: true);
                }
                if (snapshot.hasError) {
                  return const AppErrorState(
                    message: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
                  );
                }
                if (categories.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.category_outlined,
                    title: 'Chưa có danh mục',
                    message: 'Danh mục sản phẩm sẽ hiển thị tại đây.',
                  );
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final item = categories[index];
                    final icons = [
                      Icons.directions_run,
                      Icons.sports_basketball,
                      Icons.sports_soccer,
                      Icons.hiking,
                    ];
                    return InkWell(
                      borderRadius: AppRadius.mdBorder,
                      onTap: () => Navigator.pushNamed(context, '/products'),
                      child: Container(
                        width: 132,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icons[index % icons.length], size: 28),
                            const Spacer(),
                            Text(
                              item.categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${item.productCount} sản phẩm',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrending() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 32),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppSectionTitle(
              title: context.tr('trendingNow'),
              actionLabel: context.tr('shopAll'),
              onAction: () => Navigator.pushNamed(context, '/products'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 334,
            child: FutureBuilder<List<ProductModel>>(
              future: _products,
              builder: (context, snapshot) {
                final products = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingState(compact: true);
                }
                if (snapshot.hasError) {
                  return AppErrorState(
                    message: 'Đã có lỗi xảy ra. Vui lòng thử lại.',
                    onRetry: _scheduleProductsReload,
                  );
                }
                if (products.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'Không tìm thấy sản phẩm phù hợp.',
                    message: 'Hãy quay lại sau khi cửa hàng cập nhật sản phẩm.',
                  );
                }
                final visibleProducts = products.take(8).toList();
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, index) {
                    final product = visibleProducts[index];
                    return SizedBox(
                      width: 220,
                      child: AppProductCard(
                        product: product,
                        onTap: () => _openProduct(product),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool compact;

  const _HeroCopy({required this.compact});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 300 : 340),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StoreBrand(color: Colors.white, size: 34),
          SizedBox(height: compact ? 48 : 84),
          Text(
            context.tr('newSeason'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('heroTitle'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 38 : 50,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('heroSubtitle'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, height: 1.45),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.black,
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text(context.tr('shopNow')),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: AppRadius.lgBorder,
        ),
        child: Icon(
          Icons.directions_run,
          size: 150,
          color: Colors.white.withValues(alpha: 0.86),
        ),
      ),
    );
  }
}

class _MemberBanner extends StatelessWidget {
  const _MemberBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('joinTheClub'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('memberBenefits'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          IconButton.filled(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: IconButton.styleFrom(backgroundColor: AppColors.black),
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
