import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _orderService = OrderService();

  late Future<List<OrderListItem>> _ordersFuture;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = _orderService.getMyOrders();
  }

  String formatPrice(double price) {
    return formatVnd(price);
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

  String _shipmentStatusLabel(String? status) {
    return switch (status) {
      'ReadyToPick' => 'Ready to pick',
      'Picking' => 'Picking',
      'Pending' => context.tr('statusPending'),
      'Preparing' => context.tr('statusPreparing'),
      'Shipped' => context.tr('statusShipped'),
      'InTransit' => context.tr('statusInTransit'),
      'OutForDelivery' => context.tr('statusOutForDelivery'),
      'Delivered' => context.tr('statusDelivered'),
      'Failed' => context.tr('statusFailed'),
      'Returned' => context.tr('statusReturned'),
      null => context.tr('notAvailable'),
      _ => status,
    };
  }

  List<_OrderFilter> get _filters {
    return const [
      _OrderFilter('all', 'Tất cả'),
      _OrderFilter('confirming', 'Chờ xác nhận'),
      _OrderFilter('pickup', 'Chờ lấy hàng'),
      _OrderFilter('shipping', 'Chờ giao hàng'),
      _OrderFilter('delivered', 'Đã giao'),
      _OrderFilter('returning', 'Trả hàng'),
      _OrderFilter('cancelled', 'Đã hủy'),
    ];
  }

  bool _matchesFilterKey(OrderListItem order, String filterKey) {
    if (filterKey == 'all') return true;
    if (filterKey == 'returning') return order.hasReturnRequest;
    if (order.hasReturnRequest) return false;

    return switch (filterKey) {
      'confirming' =>
        order.status == 'PendingPayment' || order.status == 'Paid',
      'pickup' => order.status == 'Processing',
      'shipping' => order.status == 'Shipping',
      'delivered' => order.status == 'Delivered' || order.status == 'Completed',
      'cancelled' => order.status == 'Cancelled',
      _ => true,
    };
  }

  bool _matchesFilter(OrderListItem order) {
    return _matchesFilterKey(order, _selectedFilter);
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

  Widget _buildItemImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        width: 64,
        height: 64,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 64,
          height: 64,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image_outlined),
        );
      },
    );
  }

  Widget _buildPurchasedItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildItemImage(item.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('productSize')}: ${item.size}  '
                  '${context.tr('productColor')}: ${item.color}',
                ),
                const SizedBox(height: 2),
                Text('${context.tr('quantity')}: ${item.quantity}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPrice(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderListItem order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _goToDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatPrice(order.finalAmount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${context.tr('orderStatus')}: ${_statusLabel(order.status)}',
              ),
              Text(
                '${context.tr('payment')}: '
                '${order.paymentMethod ?? context.tr('notAvailable')}'
                ' / ${order.paymentStatus ?? context.tr('notAvailable')}',
              ),
              Text(
                '${context.tr('shipmentStatus')}: '
                '${_shipmentStatusLabel(order.shipmentStatus)}',
              ),
              Text(
                '${context.tr('createdAt')}: ${formatDate(order.createdAt)}',
              ),
              ...order.items.map(_buildPurchasedItem),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<OrderListItem> orders) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: _filters.map((filter) {
          final count = filter.key == 'all'
              ? orders.length
              : orders
                    .where((order) => _matchesFilterKey(order, filter.key))
                    .length;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${filter.label} ($count)'),
              selected: _selectedFilter == filter.key,
              onSelected: (_) {
                setState(() => _selectedFilter = filter.key);
              },
            ),
          );
        }).toList(),
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

        final filteredOrders = orders.where(_matchesFilter).toList();

        return Column(
          children: [
            _buildFilters(orders),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: filteredOrders.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: Center(
                              child: Text(context.tr('noOrdersYet')),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderItem(filteredOrders[index]);
                        },
                      ),
              ),
            ),
          ],
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

class _OrderFilter {
  final String key;
  final String label;

  const _OrderFilter(this.key, this.label);
}
