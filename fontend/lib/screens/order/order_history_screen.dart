import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();

  late Future<List<OrderListItem>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.getMyOrders();
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  String formatDate(DateTime? date) {
    if (date == null) return context.tr('notAvailable');

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(String status) {
    return switch (status) {
      'PendingPayment' => context.tr('statusPendingPayment'),
      'Paid' => context.tr('statusPaid'),
      'Processing' => context.tr('statusProcessing'),
      'Shipping' => context.tr('statusShipping'),
      'Delivered' => context.tr('statusDelivered'),
      'Cancelled' => context.tr('statusCancelled'),
      'Completed' => context.tr('statusCompleted'),
      _ => status,
    };
  }

  Future<void> _refresh() async {
    setState(() {
      _loadOrders();
    });
  }

  void _goToDetail(OrderListItem order) {
    Navigator.pushNamed(
      context,
      '/order-detail',
      arguments: order.orderId,
    ).then((_) => _refresh());
  }

  Widget _buildOrderItem(OrderListItem order) {
    return Card(
      child: ListTile(
        onTap: () => _goToDetail(order),
        title: Text(
          order.orderCode,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${context.tr('orderStatus')}: ${_statusLabel(order.status)}\n'
          '${context.tr('payment')}: ${order.paymentMethod ?? context.tr('notAvailable')}'
          ' / ${order.paymentStatus ?? context.tr('notAvailable')}\n'
          '${context.tr('createdAt')}: ${formatDate(order.createdAt)}',
        ),
        isThreeLine: true,
        trailing: Text(
          formatPrice(order.finalAmount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<OrderListItem>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          final message = snapshot.error.toString().replaceFirst(
            'Exception: ',
            '',
          );

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${context.tr('error')}: $message'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text(context.tr('retry')),
                  ),
                  if (message == 'Login required')
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(context.tr('goToLogin')),
                    ),
                ],
              ),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return Center(child: Text(context.tr('noOrdersYet')));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderItem(orders[index]);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('myOrders'))),
      body: _buildBody(),
    );
  }
}
