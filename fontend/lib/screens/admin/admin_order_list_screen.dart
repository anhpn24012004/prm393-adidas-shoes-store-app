import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/admin_model.dart';
import '../../services/admin_service.dart';
import '../../services/shipment_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'admin_shipment_detail_screen.dart';

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

  String _statusLabel(String? status) {
    return switch (status) {
      'PendingPayment' => context.tr('statusPendingPayment'),
      'Paid' => context.tr('statusPaid'),
      'Processing' => context.tr('statusProcessing'),
      'Shipping' => context.tr('statusShipping'),
      'Delivered' => context.tr('statusDelivered'),
      'Completed' => context.tr('statusCompleted'),
      'Cancelled' => context.tr('statusCancelled'),
      null => context.tr('notAvailable'),
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('orderManagement'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => setState(_reload),
              decoration: InputDecoration(
                hintText: context.tr('adminOrderSearchHint'),
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
                  label: Text(context.tr('all')),
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
                      label: Text(_statusLabel(status)),
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
                  return Center(child: Text(context.tr('adminNoOrders')));
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
                            '${order.customerName}\n${_statusLabel(order.status)} - ${order.paymentStatus ?? context.tr('unpaid')}',
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
  final _shipmentService = ShipmentService();
  late Future<AdminOrderDetail> _future;
  bool _updating = false;

  @override
  void initState() {
    super.initState();
    _future = _service.getOrder(widget.orderId);
  }

  String _statusLabel(String? status) {
    return switch (status) {
      'PendingPayment' => context.tr('statusPendingPayment'),
      'Paid' => context.tr('statusPaid'),
      'Processing' => context.tr('statusProcessing'),
      'Shipping' => context.tr('statusShipping'),
      'Delivered' => context.tr('statusDelivered'),
      'Completed' => context.tr('statusCompleted'),
      'Cancelled' => context.tr('statusCancelled'),
      null => context.tr('notAvailable'),
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

  String _formatDate(DateTime? date) {
    if (date == null) return context.tr('notAvailable');
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _reloadDetail() {
    _future = _service.getOrder(widget.orderId);
  }

  Future<void> _completeOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark order completed?'),
        content: const Text(
          'Use this admin fallback only when the customer has received the order.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel').toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('MARK COMPLETED'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _updateOrderStatus('Completed');
  }

  Future<void> _cancelOrder(AdminOrderDetail order) async {
    if (order.summary.status != 'Processing' || order.shipmentId != null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel order?'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel').toUpperCase()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CANCEL ORDER'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _updateOrderStatus('Cancelled');
  }

  Future<void> _updateOrderStatus(String status) async {
    setState(() => _updating = true);
    try {
      await _service.updateOrderStatus(widget.orderId, status);
      if (mounted) setState(_reloadDetail);
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

  Future<void> _createGhnShipment() async {
    setState(() => _updating = true);
    try {
      await _shipmentService.createShipment(
        orderId: widget.orderId,
        carrier: '',
        trackingNumber: '',
      );
      if (mounted) setState(_reloadDetail);
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

  Future<void> _syncGhnStatus(AdminOrderDetail order) async {
    final shipmentId = order.shipmentId;
    if (shipmentId == null) return;

    setState(() => _updating = true);
    try {
      await _shipmentService.syncGhnStatus(shipmentId);
      if (mounted) setState(_reloadDetail);
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

  Future<void> _viewShipment(AdminOrderDetail order) async {
    final shipmentId = order.shipmentId;
    if (shipmentId == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminShipmentDetailScreen(shipmentId: shipmentId),
      ),
    );

    if (mounted) setState(_reloadDetail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('orderDetail'))),
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
                _statusLabel(order.summary.status),
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Divider(height: 36),
              _line('Order status', _statusLabel(order.summary.status)),
              _line(
                'Payment status',
                order.summary.paymentStatus ?? context.tr('notAvailable'),
              ),
              _line(
                'Shipment status',
                _shipmentStatusLabel(order.shipmentStatus),
              ),
              const Divider(height: 36),
              _line(context.tr('customer'), order.summary.customerName),
              _line('Email', order.summary.customerEmail),
              _line(context.tr('receiver'), order.summary.receiverName),
              _line(context.tr('phoneNumber'), order.summary.receiverPhone),
              _line(context.tr('address'), order.shippingAddress),
              const Divider(height: 36),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${item.size} / ${item.color} - ${item.quantity} ${context.tr('items')}',
                  ),
                  trailing: Text(formatVnd(item.subtotal)),
                ),
              ),
              const Divider(height: 36),
              _line(context.tr('total'), formatVnd(order.summary.finalAmount)),
              _line(
                context.tr('payment'),
                '${order.summary.paymentMethod ?? context.tr('notAvailable')} / ${order.summary.paymentStatus ?? context.tr('notAvailable')}',
              ),
              const Divider(height: 36),
              _line(
                context.tr('shipment'),
                order.shipmentId == null
                    ? context.tr('notAvailable')
                    : '#${order.shipmentId}',
              ),
              _line(
                'GhnOrderCode',
                order.ghnOrderCode ?? context.tr('notAvailable'),
              ),
              _line(
                'TrackingCode',
                order.trackingCode ?? context.tr('notAvailable'),
              ),
              _line(
                'ExpectedDeliveryTime',
                _formatDate(order.expectedDeliveryTime),
              ),
              const SizedBox(height: 20),
              if (order.summary.status == 'Processing' &&
                  order.shipmentId == null)
                ElevatedButton.icon(
                  onPressed: _updating ? null : _createGhnShipment,
                  icon: const Icon(Icons.local_shipping),
                  label: Text(
                    _updating ? context.tr('updating') : 'Create GHN Shipment',
                  ),
                ),
              if (order.summary.status == 'Processing' &&
                  order.shipmentId == null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _updating ? null : () => _cancelOrder(order),
                  icon: const Icon(Icons.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  label: const Text('Cancel Order'),
                ),
              ],
              if (order.shipmentId != null) ...[
                OutlinedButton.icon(
                  onPressed: _updating ? null : () => _viewShipment(order),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View Shipment Detail'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _updating ? null : () => _syncGhnStatus(order),
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync GHN Status'),
                ),
              ],
              if (order.summary.status == 'Delivered') ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _updating ? null : _completeOrder,
                  child: const Text('MARK COMPLETED'),
                ),
              ],
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
