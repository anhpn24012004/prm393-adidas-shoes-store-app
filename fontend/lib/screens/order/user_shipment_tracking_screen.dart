import 'package:flutter/material.dart';

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
    if (date == null) return 'N/A';

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _label(String status) {
    switch (status) {
      case 'InTransit':
        return 'In Transit';
      case 'OutForDelivery':
        return 'Out for Delivery';
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
            tracking.orderCode ?? 'Shipment Tracking',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Order status: ${tracking.orderStatus ?? 'N/A'}'),
          const SizedBox(height: 16),
          const Text(
            'Tracking Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTimeline(tracking.shipmentStatus),
          const SizedBox(height: 16),
          _infoRow('Shipment status', tracking.shipmentStatus ?? 'N/A'),
          _infoRow('Carrier', tracking.carrier ?? 'N/A'),
          _infoRow('Tracking number', tracking.trackingNumber ?? 'N/A'),
          _infoRow(
            'Estimated delivery',
            _formatDate(tracking.estimatedDeliveryDate),
          ),
          _infoRow('Shipped at', _formatDate(tracking.shippedAt)),
          _infoRow('Delivered at', _formatDate(tracking.deliveredAt)),
          _infoRow('Receiver', tracking.receiverName ?? 'N/A'),
          _infoRow('Receiver phone', tracking.receiverPhone ?? 'N/A'),
          _infoRow('Shipping address', tracking.shippingAddress ?? 'N/A'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Shipment')),
      body: _orderId == null
          ? const Center(child: Text('Order ID is missing'))
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
                          Text('Error: $message'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _refresh,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tracking = snapshot.data;

                if (tracking == null) {
                  return const Center(
                    child: Text('Shipment information is not available yet'),
                  );
                }

                return _buildBody(tracking);
              },
            ),
    );
  }
}
