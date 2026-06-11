import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/store_brand.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();
  late Future<AdminDashboardModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StoreBrand(size: 27),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: FutureBuilder<AdminDashboardModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _future = _service.getDashboard()),
                child: const Text('RETRY'),
              ),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'ADMIN\nDASHBOARD.',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: [
                  _Metric('REVENUE', _money(data.totalRevenue), AppColors.blue),
                  _Metric('ORDERS', '${data.totalOrders}', AppColors.black),
                  _Metric('PRODUCTS', '${data.totalProducts}', Colors.black87),
                  _Metric('CUSTOMERS', '${data.totalUsers}', Colors.black54),
                  _Metric('PENDING', '${data.pendingOrders}', Colors.orange),
                  _Metric('RETURNS', '${data.totalRefundRequests}', Colors.red),
                ],
              ),
              const SizedBox(height: 24),
              _AdminLink(
                icon: Icons.receipt_long_outlined,
                title: 'Manage orders',
                onTap: () => Navigator.pushNamed(context, '/admin/orders'),
              ),
              _AdminLink(
                icon: Icons.inventory_2_outlined,
                title: 'Products & inventory',
                onTap: () => Navigator.pushNamed(context, '/admin/products'),
              ),
              _AdminLink(
                icon: Icons.assignment_return_outlined,
                title: 'Returns & refunds',
                onTap: () =>
                    Navigator.pushNamed(context, '/admin/returns-refunds'),
              ),
              _AdminLink(
                icon: Icons.local_shipping_outlined,
                title: 'Shipments',
                onTap: () => Navigator.pushNamed(context, '/admin/shipments'),
              ),
              _AdminLink(
                icon: Icons.category_outlined,
                title: 'Categories',
                onTap: () => Navigator.pushNamed(context, '/admin/categories'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _money(double value) => '${value.toStringAsFixed(0)}đ';
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminLink({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
