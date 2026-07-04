import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../models/product_model.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/notification_bell.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  final _productService = ProductService();

  late Future<_DashboardSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDashboard();
  }

  Future<_DashboardSnapshot> _loadDashboard() async {
    AdminDashboardModel dashboard = _DashboardSnapshot.emptyDashboard;
    List<AdminOrderSummary> orders = const [];
    PagedProductResponse? products;
    final errors = <String>[];

    try {
      dashboard = await _adminService.getDashboard();
    } catch (error) {
      errors.add('Unable to load dashboard data');
    }

    try {
      orders = await _adminService.getOrders();
      orders.sort((a, b) {
        final first = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final second = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return second.compareTo(first);
      });
    } catch (error) {
      errors.add('Unable to load recent orders');
    }

    try {
      products = await _productService.getAdminProducts(pageSize: 50);
    } catch (error) {
      errors.add('Unable to load product health');
    }

    return _DashboardSnapshot(
      dashboard: dashboard,
      recentOrders: orders.take(5).toList(),
      products: products?.items ?? const [],
      errors: errors,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadDashboard();
    });
  }

  Future<void> _openAddProduct() async {
    final result = await Navigator.pushNamed(context, '/admin/products/create');

    if (result == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          const NotificationBell(),
          IconButton(
            tooltip: 'Account',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<_DashboardSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final data = snapshot.data ?? _DashboardSnapshot.empty();

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final statColumns = width >= 1000
                      ? 4
                      : width >= 600
                      ? 3
                      : 2;
                  final actionColumns = width >= 900
                      ? 3
                      : width >= 600
                      ? 2
                      : 1;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(loading: loading, onRefresh: _reload),
                          const SizedBox(height: 16),
                          if (data.errors.isNotEmpty)
                            _InlineErrorCard(messages: data.errors),
                          if (data.errors.isNotEmpty)
                            const SizedBox(height: 16),
                          _SummaryGrid(
                            loading: loading,
                            columns: statColumns,
                            cards: _summaryCards(data),
                          ),
                          const SizedBox(height: 22),
                          _SectionHeader(
                            title: 'Quick Actions',
                            subtitle: 'Common admin workflows',
                          ),
                          const SizedBox(height: 12),
                          _QuickActionGrid(
                            columns: actionColumns,
                            actions: [
                              _QuickAction(
                                icon: Icons.inventory_2_outlined,
                                title: 'Manage Products',
                                subtitle: 'Edit catalog, images and variants',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/products',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.add_box_outlined,
                                title: 'Add Product',
                                subtitle: 'Create a draft product',
                                onTap: _openAddProduct,
                              ),
                              _QuickAction(
                                icon: Icons.receipt_long_outlined,
                                title: 'Manage Orders',
                                subtitle: 'Review and update order status',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/orders',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.people_outline,
                                title: 'Manage Users',
                                subtitle: 'Customers and admin accounts',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/users',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.local_shipping_outlined,
                                title: 'Shipments',
                                subtitle: 'Tracking and delivery updates',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/shipments',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.assignment_return_outlined,
                                title: 'Refund Requests',
                                subtitle: 'Manual refunds and approvals',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/refund-requests',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.undo_outlined,
                                title: 'Returns & Refunds',
                                subtitle: 'Return requests and manual refunds',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/returns-refunds',
                                ),
                              ),
                              _QuickAction(
                                icon: Icons.campaign_outlined,
                                title: 'Marketing Notifications',
                                subtitle: 'Broadcast deals to customers',
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/admin/marketing-notifications',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _ResponsiveTwoColumn(
                            wide: width >= 850,
                            left: _RecentOrdersPanel(
                              orders: data.recentOrders,
                              loading: loading,
                            ),
                            right: _ProductHealthPanel(
                              products: data.products,
                              loading: loading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<_SummaryCardData> _summaryCards(_DashboardSnapshot data) {
    final dashboard = data.dashboard;
    final products = data.products;
    final activeProducts = products.where((product) => product.isActive).length;
    final lowStockItems = products
        .where((product) => product.totalStock > 0 && product.totalStock <= 5)
        .length;

    return [
      _SummaryCardData(
        icon: Icons.inventory_2_outlined,
        label: 'Total Products',
        value: '${dashboard.totalProducts}',
        color: Colors.black,
      ),
      _SummaryCardData(
        icon: Icons.verified_outlined,
        label: 'Active Products',
        value: '$activeProducts',
        color: const Color(0xFF1F7A4D),
      ),
      _SummaryCardData(
        icon: Icons.pending_actions_outlined,
        label: 'Pending Orders',
        value: '${dashboard.pendingOrders}',
        color: const Color(0xFF805C00),
      ),
      _SummaryCardData(
        icon: Icons.people_outline,
        label: 'Total Users',
        value: '${dashboard.totalUsers}',
        color: const Color(0xFF3A4A66),
      ),
      _SummaryCardData(
        icon: Icons.payments_outlined,
        label: 'Total Revenue',
        value: _compactMoney(dashboard.totalRevenue),
        color: const Color(0xFF345A45),
      ),
      _SummaryCardData(
        icon: Icons.warning_amber_outlined,
        label: 'Low Stock Items',
        value: '$lowStockItems',
        color: const Color(0xFF7A3E24),
      ),
    ];
  }

  static String _compactMoney(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class _Header extends StatelessWidget {
  final bool loading;
  final VoidCallback onRefresh;

  const _Header({required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Admin',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loading
                      ? 'Loading store operations...'
                      : 'Your store overview is ready',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            tooltip: 'Refresh dashboard',
            onPressed: loading ? null : onRefresh,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final bool loading;
  final int columns;
  final List<_SummaryCardData> cards;

  const _SummaryGrid({
    required this.loading,
    required this.columns,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 2 ? 1.28 : 1.55,
      ),
      itemBuilder: (context, index) {
        return _SummaryCard(data: cards[index], loading: loading);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;
  final bool loading;

  const _SummaryCard({required this.data, required this.loading});

  @override
  Widget build(BuildContext context) {
    final tint = data.color.withValues(alpha: .09);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color),
          ),
          const Spacer(),
          loading
              ? const _LoadingBar(width: 64, height: 22)
              : Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  final int columns;
  final List<_QuickAction> actions;

  const _QuickActionGrid({required this.columns, required this.actions});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 4.1 : 3.2,
      ),
      itemBuilder: (context, index) {
        return _QuickActionCard(action: actions[index]);
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: AppColors.black),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ResponsiveTwoColumn extends StatelessWidget {
  final bool wide;
  final Widget left;
  final Widget right;

  const _ResponsiveTwoColumn({
    required this.wide,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(children: [left, const SizedBox(height: 16), right]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: left),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: right),
      ],
    );
  }
}

class _RecentOrdersPanel extends StatelessWidget {
  final List<AdminOrderSummary> orders;
  final bool loading;

  const _RecentOrdersPanel({required this.orders, required this.loading});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Orders',
            subtitle: 'Latest customer purchases',
            actionLabel: 'View all',
            onAction: () => Navigator.pushNamed(context, '/admin/orders'),
          ),
          const SizedBox(height: 14),
          if (loading)
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _OrderSkeleton(),
              ),
            )
          else if (orders.isEmpty)
            const _EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'No recent activity yet',
            )
          else
            ...orders.map((order) => _RecentOrderTile(order: order)),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final AdminOrderSummary order;

  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final orderCode = order.orderCode.isNotEmpty
        ? order.orderCode
        : '#${order.orderId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  order.customerName.isEmpty
                      ? 'Unknown customer'
                      : order.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatVnd(order.finalAmount),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              _StatusBadge(label: order.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductHealthPanel extends StatelessWidget {
  final List<ProductModel> products;
  final bool loading;

  const _ProductHealthPanel({required this.products, required this.loading});

  @override
  Widget build(BuildContext context) {
    final draftProducts = products.where((product) => !product.isActive).length;
    final missingImages = products
        .where((product) => product.imageCount == 0)
        .length;
    final missingVariants = products
        .where((product) => product.activeVariantCount == 0)
        .length;
    final outOfStock = products
        .where((product) => product.totalStock <= 0)
        .length;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Product Health',
            subtitle: 'Catalog readiness checks',
            actionLabel: 'Products',
            onAction: () => Navigator.pushNamed(context, '/admin/products'),
          ),
          const SizedBox(height: 14),
          if (loading)
            ...List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: _LoadingBar(width: double.infinity, height: 54),
              ),
            )
          else ...[
            _HealthRow(
              icon: Icons.drafts_outlined,
              label: 'Draft products',
              count: draftProducts,
            ),
            _HealthRow(
              icon: Icons.image_not_supported_outlined,
              label: 'Missing image',
              count: missingImages,
            ),
            _HealthRow(
              icon: Icons.inventory_outlined,
              label: 'Missing variant',
              count: missingVariants,
            ),
            _HealthRow(
              icon: Icons.report_gmailerrorred_outlined,
              label: 'Out of stock',
              count: outOfStock,
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _HealthRow({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final attention = count > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: attention ? const Color(0xFFFFF7E6) : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: attention ? const Color(0xFF805C00) : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;

  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    final color = normalized.contains('pending')
        ? const Color(0xFF805C00)
        : normalized.contains('complete') || normalized.contains('delivered')
        ? const Color(0xFF1F7A4D)
        : normalized.contains('cancel') || normalized.contains('reject')
        ? const Color(0xFF8A1F1F)
        : const Color(0xFF3A4A66);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.isEmpty ? 'Unknown' : label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  final List<String> messages;

  const _InlineErrorCard({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0A3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF805C00)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              messages.toSet().join('\n'),
              style: const TextStyle(
                color: Color(0xFF4A3600),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  final double width;
  final double height;

  const _LoadingBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _OrderSkeleton extends StatelessWidget {
  const _OrderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          _LoadingBar(width: 42, height: 42),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LoadingBar(width: 120, height: 14),
                SizedBox(height: 8),
                _LoadingBar(width: 170, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          _LoadingBar(width: 78, height: 24),
        ],
      ),
    );
  }
}

class _DashboardSnapshot {
  final AdminDashboardModel dashboard;
  final List<AdminOrderSummary> recentOrders;
  final List<ProductModel> products;
  final List<String> errors;

  const _DashboardSnapshot({
    required this.dashboard,
    required this.recentOrders,
    required this.products,
    required this.errors,
  });

  factory _DashboardSnapshot.empty() {
    return const _DashboardSnapshot(
      dashboard: emptyDashboard,
      recentOrders: [],
      products: [],
      errors: [],
    );
  }

  static const emptyDashboard = AdminDashboardModel(
    totalUsers: 0,
    activeUsers: 0,
    inactiveUsers: 0,
    totalProducts: 0,
    totalOrders: 0,
    totalRevenue: 0,
    pendingOrders: 0,
    completedOrders: 0,
    totalRefundRequests: 0,
    totalReviews: 0,
  );
}
