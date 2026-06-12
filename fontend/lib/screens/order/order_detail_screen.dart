import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../models/shipment_model.dart';
import '../../services/order_service.dart';
import '../../services/shipment_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int? orderId;

  const OrderDetailScreen({super.key, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final ShipmentService _shipmentService = ShipmentService();

  Future<OrderDetail>? _orderFuture;
  Future<ShipmentDetail?>? _shipmentFuture;
  int? _orderId;
  bool _isCancelling = false;
  PaymentStatus? _paymentStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_orderFuture != null) return;

    final argument = ModalRoute.of(context)?.settings.arguments;
    _orderId = widget.orderId ?? (argument is int ? argument : null);

    if (_orderId != null) {
      _loadOrder();
    }
  }

  void _loadOrder() {
    _orderFuture = _orderService.getOrderDetail(_orderId!);
    _shipmentFuture = _shipmentService.getUserShipment(_orderId!);
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    setState(() {
      _loadOrder();
    });
  }

  Future<void> _cancelOrder(OrderDetail order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel order'),
          content: Text('Cancel order ${order.orderCode}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cancel Order'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await _orderService.cancelOrder(order.orderId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order cancelled successfully')),
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Future<void> _refreshPaymentStatus(OrderDetail order) async {
    try {
      final status = await _orderService.getPaymentStatus(order.orderId);

      if (!mounted) return;

      setState(() {
        _paymentStatus = status;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Payment status refreshed')));

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItem(OrderItem item) {
    return Card(
      child: ListTile(
        title: Text(item.productName),
        subtitle: Text(
          'Size: ${item.size}  Color: ${item.color}\n'
          'Quantity: ${item.quantity}  Unit: ${formatPrice(item.unitPrice)}',
        ),
        isThreeLine: true,
        trailing: Text(
          formatPrice(item.subtotal),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _goToTracking(OrderDetail order) {
    Navigator.pushNamed(
      context,
      '/shipment-tracking',
      arguments: order.orderId,
    );
  }

  Widget _buildShipmentSection(OrderDetail order, ShipmentDetail? shipment) {
    final canTrack =
        shipment != null ||
        order.status == 'Shipping' ||
        order.status == 'Delivered';

    if (shipment == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Shipping'),
          const Text('Shipment information is not available yet.'),
          if (canTrack) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _goToTracking(order),
              icon: const Icon(Icons.local_shipping),
              label: const Text('Track Shipment'),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Shipping'),
        _infoRow('Shipment status', shipment.shipmentStatus ?? 'Not available'),
        _infoRow('Carrier', shipment.carrier ?? 'N/A'),
        _infoRow('Tracking number', shipment.trackingNumber ?? 'N/A'),
        _infoRow(
          'Estimated delivery',
          formatDate(shipment.estimatedDeliveryDate),
        ),
        _infoRow('Shipped at', formatDate(shipment.shippedAt)),
        _infoRow('Delivered at', formatDate(shipment.deliveredAt)),
        _infoRow('Receiver', shipment.receiverName ?? order.receiverName),
        _infoRow(
          'Receiver phone',
          shipment.receiverPhone ?? order.receiverPhone,
        ),
        _infoRow(
          'Shipping address',
          shipment.shippingAddress ?? order.shippingAddress,
        ),
        if (canTrack) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _goToTracking(order),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Track Shipment'),
          ),
        ],
      ],
    );
  }

  Widget _buildDetail(OrderDetail order, ShipmentDetail? shipment) {
    final canCancel =
        order.status == 'PendingPayment' || order.status == 'Paid';
    final paymentStatus =
        _paymentStatus?.paymentStatus ?? order.payment.paymentStatus;
    final paidAt = _paymentStatus?.paidAt ?? order.payment.paidAt;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            order.orderCode,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Status: ${order.status}'),
          _sectionTitle('Receiver'),
          _infoRow('Name', order.receiverName),
          _infoRow('Phone', order.receiverPhone),
          _infoRow('Address', order.shippingAddress),
          if (order.note != null && order.note!.isNotEmpty)
            _infoRow('Note', order.note!),
          _sectionTitle('Items'),
          ...order.items.map(_buildItem),
          _buildShipmentSection(order, shipment),
          _sectionTitle('Payment'),
          _infoRow('Method', order.payment.paymentMethod ?? 'N/A'),
          _infoRow('Status', paymentStatus ?? 'N/A'),
          _infoRow('Paid at', formatDate(paidAt)),
          _sectionTitle('Totals'),
          _infoRow('Total amount', formatPrice(order.totalAmount)),
          _infoRow('Shipping fee', formatPrice(order.shippingFee)),
          _infoRow('Discount', formatPrice(order.discountAmount)),
          _infoRow('Final amount', formatPrice(order.finalAmount)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _refreshPaymentStatus(order),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Payment Status'),
          ),
          if (order.status == 'Delivered' || order.status == 'Completed') ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(
                context,
                '/refund-request',
                arguments: order.orderId,
              ),
              icon: const Icon(Icons.assignment_return_outlined),
              label: const Text('Request Return'),
            ),
          ],
          if (canCancel) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCancelling ? null : () => _cancelOrder(order),
              icon: _isCancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cancel),
              label: const Text('Cancel Order'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderFuture = _orderFuture;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Detail')),
      body: _orderId == null
          ? const Center(child: Text('Order ID is missing'))
          : FutureBuilder<OrderDetail>(
              future: orderFuture,
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
                          Text('Error: $message'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                          if (message == 'Login required')
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const Text('Go to Login'),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                final order = snapshot.data;

                if (order == null) {
                  return const Center(child: Text('Order not found'));
                }

                return FutureBuilder<ShipmentDetail?>(
                  future: _shipmentFuture,
                  builder: (context, shipmentSnapshot) {
                    if (shipmentSnapshot.hasError) {
                      return _buildDetail(order, null);
                    }

                    return _buildDetail(order, shipmentSnapshot.data);
                  },
                );
              },
            ),
    );
  }
}
