import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../models/review_model.dart';
import '../../models/shipment_model.dart';
import '../../services/order_service.dart';
import '../../services/review_service.dart';
import '../../services/shipment_service.dart';
import '../../utils/currency_formatter.dart';

class OrderDetailScreen extends StatefulWidget {
  final int? orderId;

  const OrderDetailScreen({super.key, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final ShipmentService _shipmentService = ShipmentService();
  final ReviewService _reviewService = ReviewService();

  Future<OrderDetail>? _orderFuture;
  Future<ShipmentDetail?>? _shipmentFuture;
  int? _orderId;
  bool _isCancelling = false;
  bool _isCompleting = false;
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

  String _statusLabel(String? status) {
    return switch (status) {
      'PendingPayment' => context.tr('statusPendingPayment'),
      'Paid' => context.tr('statusPaid'),
      'Processing' => context.tr('statusProcessing'),
      'Shipping' => context.tr('statusShipping'),
      'Delivered' => context.tr('statusDelivered'),
      'Cancelled' => context.tr('statusCancelled'),
      'Completed' => context.tr('statusCompleted'),
      'Pending' => context.tr('statusPendingPayment'),
      null => context.tr('notAvailable'),
      _ => status,
    };
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
          title: Text(context.tr('cancelOrder')),
          content: Text(
            '${context.tr('cancelOrderQuestion')} ${order.orderCode}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('cancelOrder')),
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('orderCancelled'))));

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('paymentStatusRefreshed'))),
      );

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

  Future<void> _writeReview(OrderItem item) async {
    final created = await Navigator.pushNamed(
      context,
      '/create-review',
      arguments: item.productId,
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('reviewSubmitted'))));
    }
  }

  Future<void> _editReview(OrderItem item, ReviewResponse review) async {
    final updated = await Navigator.pushNamed(
      context,
      '/create-review',
      arguments: {
        'productId': item.productId,
        'reviewId': review.reviewId,
        'rating': review.rating,
        'comment': review.comment,
      },
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('reviewSubmitted'))));
      setState(() {});
    }
  }

  Widget _buildReviewAction(OrderItem item) {
    return FutureBuilder<ReviewResponse?>(
      future: _reviewService.getUserReview(
        userId: AppConfig.currentUserId,
        productId: item.productId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final review = snapshot.data;

        if (review == null) {
          return OutlinedButton.icon(
            onPressed: () => _writeReview(item),
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(context.tr('writeReview')),
          );
        }

        if (review.canEdit) {
          return OutlinedButton.icon(
            onPressed: () => _editReview(item, review),
            icon: const Icon(Icons.edit_outlined),
            label: Text(context.tr('editReview')),
          );
        }

        return OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.lock_outline),
          label: Text(context.tr('reviewLocked')),
        );
      },
    );
  }

  Future<void> _completeOrder(OrderDetail order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr('confirmReceived')),
          content: Text(context.tr('confirmReceivedMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.tr('confirm')),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isCompleting = true);

    try {
      await _orderService.completeOrder(order.orderId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('orderCompleted'))));

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
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

  Widget _buildItem(OrderItem item, {required bool canReview}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr('productSize')}: ${item.size}  '
                    '${context.tr('productColor')}: ${item.color}\n'
                    '${context.tr('quantity')}: ${item.quantity}  '
                    '${context.tr('unitPrice')}: ${formatPrice(item.unitPrice)}',
                  ),
                  if (canReview && item.productId > 0) ...[
                    const SizedBox(height: 10),
                    _buildReviewAction(item),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatPrice(item.subtotal),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
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
          _sectionTitle(context.tr('shipping')),
          Text(context.tr('shipmentFallback')),
          const SizedBox(height: 6),
          _infoRow(context.tr('orderStatus'), _statusLabel(order.status)),
          if (canTrack) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _goToTracking(order),
              icon: const Icon(Icons.local_shipping),
              label: Text(context.tr('trackShipment')),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context.tr('shipping')),
        _infoRow(
          context.tr('shipmentStatus'),
          _statusLabel(shipment.shipmentStatus),
        ),
        _infoRow(
          context.tr('carrier'),
          shipment.carrier ?? context.tr('notAvailable'),
        ),
        _infoRow(
          context.tr('trackingNumber'),
          shipment.trackingNumber ?? context.tr('notAvailable'),
        ),
        _infoRow(
          context.tr('estimatedDelivery'),
          formatDate(shipment.estimatedDeliveryDate),
        ),
        _infoRow(context.tr('shippedAt'), formatDate(shipment.shippedAt)),
        _infoRow(context.tr('deliveredAt'), formatDate(shipment.deliveredAt)),
        _infoRow(
          context.tr('receiver'),
          shipment.receiverName ?? order.receiverName,
        ),
        _infoRow(
          context.tr('receiverPhone'),
          shipment.receiverPhone ?? order.receiverPhone,
        ),
        _infoRow(
          context.tr('shippingAddress'),
          shipment.shippingAddress ?? order.shippingAddress,
        ),
        if (canTrack) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _goToTracking(order),
            icon: const Icon(Icons.local_shipping),
            label: Text(context.tr('trackShipment')),
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
    final canReview = order.canReview;

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
          Text('${context.tr('orderStatus')}: ${_statusLabel(order.status)}'),
          _sectionTitle(context.tr('receiver')),
          _infoRow(context.tr('name'), order.receiverName),
          _infoRow(context.tr('phoneNumber'), order.receiverPhone),
          _infoRow(context.tr('address'), order.shippingAddress),
          if (order.note != null && order.note!.isNotEmpty)
            _infoRow(context.tr('note'), order.note!),
          _sectionTitle(context.tr('items')),
          ...order.items.map((item) => _buildItem(item, canReview: canReview)),
          _buildShipmentSection(order, shipment),
          _sectionTitle(context.tr('payment')),
          _infoRow(
            context.tr('paymentMethod'),
            order.payment.paymentMethod ?? context.tr('notAvailable'),
          ),
          _infoRow(context.tr('paymentStatus'), _statusLabel(paymentStatus)),
          _infoRow(context.tr('paidAt'), formatDate(paidAt)),
          _sectionTitle(context.tr('totals')),
          _infoRow(context.tr('totalAmount'), formatPrice(order.totalAmount)),
          _infoRow(context.tr('shippingFee'), formatPrice(order.shippingFee)),
          _infoRow(context.tr('discount'), formatPrice(order.discountAmount)),
          _infoRow(context.tr('finalAmount'), formatPrice(order.finalAmount)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _refreshPaymentStatus(order),
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('refreshPaymentStatus')),
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
              label: Text(context.tr('requestReturn')),
            ),
          ],
          if (order.status == 'Delivered') ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isCompleting ? null : () => _completeOrder(order),
              icon: _isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(context.tr('confirmReceived')),
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
              label: Text(context.tr('cancelOrder')),
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
      appBar: AppBar(title: Text(context.tr('orderDetail'))),
      body: _orderId == null
          ? Center(child: Text(context.tr('orderIdMissing')))
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
                          Text('${context.tr('error')}: $message'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: Text(context.tr('retry')),
                          ),
                          if (message == 'Login required')
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: Text(context.tr('goToLogin')),
                            ),
                        ],
                      ),
                    ),
                  );
                }

                final order = snapshot.data;

                if (order == null) {
                  return Center(child: Text(context.tr('orderNotFound')));
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
