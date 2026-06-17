import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  final _service = AdminService();
  final _searchController = TextEditingController();
  String? _status;
  late Future<List<AdminOrderSummary>> _future;

  static const _statuses = [
    'PendingPayment',
    'Paid',
    'Processing',
    'Shipping',
    'Delivered',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getOrders(
      status: _status,
      keyword: _searchController.text.trim(),
    );
  }

  Future<void> _openOrder(AdminOrderSummary order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminOrderDetailScreen(orderId: order.orderId),
      ),
    );
    if (mounted) setState(_reload);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ORDER MANAGEMENT')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => setState(_reload),
              decoration: InputDecoration(
                hintText: 'Order code, customer or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => setState(_reload),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _status == null,
                  onSelected: (_) => setState(() {
                    _status = null;
                    _reload();
                  }),
                ),
                const SizedBox(width: 8),
                ..._statuses.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: _status == status,
                      onSelected: (_) => setState(() {
                        _status = status;
                        _reload();
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AdminOrderSummary>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                    ),
                  );
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_reload);
                    await _future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          onTap: () => _openOrder(order),
                          title: Text(
                            order.orderCode,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            '${order.customerName}\n${order.status} • ${order.paymentStatus ?? 'Unpaid'}',
                          ),
                          isThreeLine: true,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatVnd(order.finalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final _service = AdminService();
  late Future<AdminOrderDetail> _future;
  bool _updating = false;

  static const _statuses = [
    'PendingPayment',
    'Paid',
    'Processing',
    'Shipping',
    'Delivered',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _future = _service.getOrder(widget.orderId);
  }

  Future<void> _changeStatus(AdminOrderDetail order) async {
    var selected = order.summary.status;
    final status = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update order status'),
          content: DropdownButtonFormField<String>(
            initialValue: _statuses.contains(selected) ? selected : null,
            items: _statuses
                .map(
                  (value) => DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
            onChanged: (value) =>
                setDialogState(() => selected = value ?? selected),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
    if (status == null || status == order.summary.status) return;
    setState(() => _updating = true);
    try {
      await _service.updateOrderStatus(widget.orderId, status);
      if (mounted) setState(() => _future = _service.getOrder(widget.orderId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ORDER DETAIL')),
      body: FutureBuilder<AdminOrderDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final order = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                order.summary.orderCode,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                order.summary.status,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Divider(height: 36),
              _line('Customer', order.summary.customerName),
              _line('Email', order.summary.customerEmail),
              _line('Receiver', order.summary.receiverName),
              _line('Phone', order.summary.receiverPhone),
              _line('Address', order.shippingAddress),
              const Divider(height: 36),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${item.size} / ${item.color} • ${item.quantity} pcs',
                  ),
                  trailing: Text(formatVnd(item.subtotal)),
                ),
              ),
              const Divider(height: 36),
              _line(
                'Total',
                formatVnd(order.summary.finalAmount),
              ),
              _line(
                'Payment',
                '${order.summary.paymentMethod ?? 'N/A'} / ${order.summary.paymentStatus ?? 'N/A'}',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updating ? null : () => _changeStatus(order),
                child: Text(_updating ? 'UPDATING...' : 'UPDATE ORDER STATUS'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
