import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../localization/app_localization.dart';
import '../../providers/badge_notifier.dart';
import '../../services/category_service.dart';
import '../../services/inventory_realtime_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cart_wishlist_badges.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/product_rating.dart';
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
        .instance.stockChangedStream
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHero()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildTrending()),
          const SliverToBoxAdapter(child: _MemberBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
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
    return Container(
      height: 390,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: AppColors.black),
      child: Stack(
        children: [
          Positioned(
            right: -45,
            top: 20,
            child: Transform.rotate(
              angle: -.22,
              child: Icon(
                Icons.sports_soccer,
                size: 245,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('newSeason').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const Spacer(),
              Text(
                context.tr('heroTitle').toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 54,
                  height: .88,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2.4,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('heroSubtitle'),
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.tr('shopNow').toUpperCase()),
                    const SizedBox(width: 18),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StoreSectionTitle(
              title: context.tr('shopBySport'),
              actionLabel: context.tr('viewAll'),
              onAction: () => Navigator.pushNamed(context, '/categories'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 102,
            child: FutureBuilder<List<CategoryModel>>(
              future: _categories,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                      onTap: () => Navigator.pushNamed(context, '/products'),
                      child: Container(
                        width: 118,
                        padding: const EdgeInsets.all(14),
                        color: AppColors.surface,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icons[index % icons.length], size: 28),
                            const Spacer(),
                            Text(
                              item.categoryName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
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
            child: StoreSectionTitle(
              title: context.tr('trendingNow'),
              actionLabel: context.tr('shopAll'),
              onAction: () => Navigator.pushNamed(context, '/products'),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 300,
            child: FutureBuilder<List<ProductModel>>(
              future: _products,
              builder: (context, snapshot) {
                final products = snapshot.data ?? [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (products.isEmpty) {
                  return Center(child: Text(context.tr('noProducts')));
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.take(8).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return _HomeProductCard(
                      product: product,
                      onTap: () => _openProduct(product),
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

class _HomeProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _HomeProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: AppColors.surface,
                child: product.mainImageUrl?.isNotEmpty == true
                    ? Image.network(
                        AppConfig.resolveImageUrl(product.mainImageUrl!),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Center(child: Icon(Icons.image, size: 52)),
                      )
                    : const Center(child: Icon(Icons.image, size: 52)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              product.categoryName ?? 'Originals',
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            ProductRating(
              averageRating: product.averageRating,
              reviewCount: product.reviewCount,
            ),
            const SizedBox(height: 4),
            Text(
              formatVnd(product.basePrice),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
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
      color: const Color(0xFFE9FF48),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('joinTheClub').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(context.tr('memberBenefits')),
              ],
            ),
          ),
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
