import 'package:flutter/material.dart';

import '../../models/shipment_model.dart';
import '../../services/auth_storage.dart';
import '../../services/shipment_service.dart';
import 'admin_shipment_form_screen.dart';

class AdminShipmentDetailScreen extends StatefulWidget {
  final int? shipmentId;

  const AdminShipmentDetailScreen({super.key, this.shipmentId});

  @override
  State<AdminShipmentDetailScreen> createState() =>
      _AdminShipmentDetailScreenState();
}

class _AdminShipmentDetailScreenState extends State<AdminShipmentDetailScreen> {
  final ShipmentService _shipmentService = ShipmentService();
  final AuthStorage _authStorage = AuthStorage();
  static const Map<String, List<String>> _transitions = {
    'Pending': ['Preparing'],
    'Preparing': ['Shipped'],
    'Shipped': ['InTransit'],
    'InTransit': ['OutForDelivery'],
    'OutForDelivery': ['Delivered', 'Failed'],
    'Failed': ['OutForDelivery', 'Returned'],
  };

  Future<ShipmentDetail>? _detailFuture;
  late Future<bool> _isAdminFuture;
  int? _shipmentId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_detailFuture != null) return;
    _isAdminFuture = _authStorage.isAdmin();

    final argument = ModalRoute.of(context)?.settings.arguments;
    _shipmentId = widget.shipmentId ?? (argument is int ? argument : null);

    if (_shipmentId != null) {
      _loadDetail();
    }
  }

  void _loadDetail() {
    _detailFuture = _shipmentService.getAdminShipmentDetail(_shipmentId!);
  }

  Future<void> _refresh() async {
    setState(() {
      _loadDetail();
    });
  }

  String _formatMoney(double? amount) {
    if (amount == null) return 'N/A';
    return '${amount.toStringAsFixed(0)} VND';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  List<String> _nextStatuses(String? currentStatus) {
    return _transitions[currentStatus] ?? const [];
  }

  Future<void> _editTracking(ShipmentDetail detail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminShipmentFormScreen(createMode: false, shipment: detail),
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _updateStatus(ShipmentDetail detail) async {
    final nextStatuses = _nextStatuses(detail.shipmentStatus);

    if (nextStatuses.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No valid next statuses')));
      return;
    }

    final noteController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ...nextStatuses.map((status) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(status),
                    onTap: () => Navigator.pop(context, {
                      'status': status,
                      'note': noteController.text.trim(),
                    }),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (result == null || result['status'] == null) return;

    try {
      await _shipmentService.updateShipmentStatus(
        shipmentId: detail.shipmentId!,
        status: result['status']!,
        note: (result['note'] ?? '').isEmpty ? null : result['note'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Shipment status updated to ${result['status']}'),
        ),
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
            width: 150,
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

  Widget _buildItem(ShipmentItem item) {
    return Card(
      child: ListTile(
        title: Text(item.productName ?? 'Item'),
        subtitle: Text(
          'Size: ${item.size ?? 'N/A'}  Color: ${item.color ?? 'N/A'}\n'
          'Quantity: ${item.quantity ?? 0}  Unit: ${_formatMoney(item.unitPrice)}',
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildBody(ShipmentDetail detail) {
    final locked =
        detail.shipmentStatus == 'Delivered' ||
        detail.shipmentStatus == 'Returned';

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            detail.orderCode ?? 'Shipment Detail',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Shipment status: ${detail.shipmentStatus ?? 'N/A'}'),
          _sectionTitle('Order Info'),
          _infoRow('Order status', detail.orderStatus ?? 'N/A'),
          _infoRow('Final amount', _formatMoney(detail.finalAmount)),
          _infoRow('Order total', _formatMoney(detail.totalAmount)),
          _sectionTitle('Customer Info'),
          _infoRow('Customer', detail.customerName ?? 'N/A'),
          _infoRow('Email', detail.customerEmail ?? 'N/A'),
          _infoRow('Phone', detail.customerPhone ?? 'N/A'),
          _sectionTitle('Receiver'),
          _infoRow('Receiver', detail.receiverName ?? 'N/A'),
          _infoRow('Receiver phone', detail.receiverPhone ?? 'N/A'),
          _infoRow('Address', detail.shippingAddress ?? 'N/A'),
          _sectionTitle('Payment'),
          _infoRow('Method', detail.paymentMethod ?? 'N/A'),
          _infoRow('Status', detail.paymentStatus ?? 'N/A'),
          _infoRow('Transaction', detail.transactionCode ?? 'N/A'),
          _infoRow('Paid at', _formatDate(detail.paidAt)),
          _sectionTitle('Shipment'),
          _infoRow('Carrier', detail.carrier ?? 'N/A'),
          _infoRow('Tracking number', detail.trackingNumber ?? 'N/A'),
          _infoRow(
            'Estimated delivery',
            _formatDate(detail.estimatedDeliveryDate),
          ),
          _infoRow('Shipped at', _formatDate(detail.shippedAt)),
          _infoRow('Delivered at', _formatDate(detail.deliveredAt)),
          _sectionTitle('Order Items'),
          if (detail.items.isEmpty)
            const Text('No order items returned')
          else
            ...detail.items.map(_buildItem),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: locked ? null : () => _editTracking(detail),
            icon: const Icon(Icons.local_shipping),
            label: const Text('Update Tracking Info'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: locked ? null : () => _updateStatus(detail),
            icon: const Icon(Icons.sync),
            label: const Text('Update Shipment Status'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, roleSnapshot) {
        if (!roleSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (roleSnapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shipment Detail')),
            body: const Center(child: Text('Admin access required')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Shipment Detail')),
          body: _shipmentId == null
              ? const Center(child: Text('Shipment ID is missing'))
              : FutureBuilder<ShipmentDetail>(
                  future: _detailFuture,
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

                    final detail = snapshot.data;

                    if (detail == null) {
                      return const Center(child: Text('Shipment not found'));
                    }

                    return _buildBody(detail);
                  },
                ),
        );
      },
    );
  }
}
