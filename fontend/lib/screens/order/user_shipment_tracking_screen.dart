import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/shipment_model.dart';
import '../../services/shipment_service.dart';

class UserShipmentTrackingScreen extends StatefulWidget {
  final int? orderId;

  const UserShipmentTrackingScreen({super.key, this.orderId});

  @override
  State<UserShipmentTrackingScreen> createState() =>
      _UserShipmentTrackingScreenState();
}

class _UserShipmentTrackingScreenState
    extends State<UserShipmentTrackingScreen> {
  final ShipmentService _shipmentService = ShipmentService();
  static const List<String> _statuses = [
    'Pending',
    'Preparing',
    'Shipped',
    'InTransit',
    'OutForDelivery',
    'Delivered',
    'Failed',
    'Returned',
  ];

  Future<ShipmentTracking?>? _trackingFuture;
  int? _orderId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_trackingFuture != null) return;

    final argument = ModalRoute.of(context)?.settings.arguments;
    _orderId = widget.orderId ?? (argument is int ? argument : null);

    if (_orderId != null) {
      _loadTracking();
    }
  }

  void _loadTracking() {
    _trackingFuture = _shipmentService.getUserTracking(_orderId!);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadTracking();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return context.tr('notAvailable');

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _label(String status) {
    switch (status) {
      case 'Pending':
        return context.tr('statusPending');
      case 'Preparing':
        return context.tr('statusPreparing');
      case 'Shipped':
        return context.tr('statusShipped');
      case 'InTransit':
        return context.tr('statusInTransit');
      case 'OutForDelivery':
        return context.tr('statusOutForDelivery');
      case 'Delivered':
        return context.tr('statusDelivered');
      case 'Failed':
        return context.tr('statusFailed');
      case 'Returned':
        return context.tr('statusReturned');
      default:
        return status;
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Widget _buildTimeline(String? currentStatus) {
    final currentIndex = _statuses.indexOf(currentStatus ?? '');

    return Column(
      children: _statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isActive = currentStatus == status;
        final isCompleted = currentIndex >= 0 && index <= currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isActive
                      ? Icons.radio_button_checked
                      : isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isActive || isCompleted ? Colors.green : Colors.grey,
                ),
                if (index != _statuses.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: isCompleted ? Colors.green : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _label(status),
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive || isCompleted ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBody(ShipmentTracking tracking) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            tracking.orderCode ?? context.tr('trackShipment'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${context.tr('orderStatus')}: '
            '${tracking.orderStatus ?? context.tr('notAvailable')}',
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('trackingProgress'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTimeline(tracking.shipmentStatus),
          const SizedBox(height: 16),
          _infoRow(
            context.tr('shipmentStatus'),
            tracking.shipmentStatus == null
                ? context.tr('notAvailable')
                : _label(tracking.shipmentStatus!),
          ),
          _infoRow(context.tr('carrier'), tracking.carrier ?? context.tr('notAvailable')),
          _infoRow(context.tr('trackingNumber'), tracking.trackingNumber ?? context.tr('notAvailable')),
          _infoRow(
            context.tr('estimatedDelivery'),
            _formatDate(tracking.estimatedDeliveryDate),
          ),
          _infoRow(context.tr('shippedAt'), _formatDate(tracking.shippedAt)),
          _infoRow(context.tr('deliveredAt'), _formatDate(tracking.deliveredAt)),
          _infoRow(context.tr('receiver'), tracking.receiverName ?? context.tr('notAvailable')),
          _infoRow(context.tr('receiverPhone'), tracking.receiverPhone ?? context.tr('notAvailable')),
          _infoRow(context.tr('shippingAddress'), tracking.shippingAddress ?? context.tr('notAvailable')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('trackShipment'))),
      body: _orderId == null
          ? Center(child: Text(context.tr('orderIdMissing')))
          : FutureBuilder<ShipmentTracking?>(
              future: _trackingFuture,
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
                        ],
                      ),
                    ),
                  );
                }

                final tracking = snapshot.data;

                if (tracking == null) {
                  return Center(
                    child: Text(context.tr('shipmentUnavailable')),
                  );
                }

                return _buildBody(tracking);
              },
            ),
    );
  }
}
