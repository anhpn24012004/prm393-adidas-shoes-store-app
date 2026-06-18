import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/shipment_model.dart';
import '../../services/auth_storage.dart';
import '../../services/shipment_service.dart';
import '../../utils/currency_formatter.dart';
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
    if (amount == null) return context.tr('notAvailable');
    return formatVnd(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return context.tr('notAvailable');

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
      ).showSnackBar(SnackBar(content: Text(context.tr('noNextStatus'))));
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
                  decoration: InputDecoration(
                    labelText: context.tr('noteOptional'),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ...nextStatuses.map((status) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_shipmentStatusLabel(status)),
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
          content: Text(
            '${context.tr('shipmentStatusUpdated')}: ${_shipmentStatusLabel(result['status']!)}',
          ),
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
        title: Text(item.productName ?? context.tr('items')),
        subtitle: Text(
          '${context.tr('productSize')}: ${item.size ?? context.tr('notAvailable')}  '
          '${context.tr('productColor')}: ${item.color ?? context.tr('notAvailable')}\n'
          '${context.tr('quantity')}: ${item.quantity ?? 0}  '
          '${context.tr('unitPrice')}: ${_formatMoney(item.unitPrice)}',
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
            detail.orderCode ?? context.tr('shipmentDetail'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${context.tr('shipmentStatus')}: ${detail.shipmentStatus == null ? context.tr('notAvailable') : _shipmentStatusLabel(detail.shipmentStatus!)}',
          ),
          _sectionTitle(context.tr('orderInfo')),
          _infoRow(
            context.tr('orderStatus'),
            detail.orderStatus ?? context.tr('notAvailable'),
          ),
          _infoRow(context.tr('finalAmount'), _formatMoney(detail.finalAmount)),
          _infoRow(context.tr('totalAmount'), _formatMoney(detail.totalAmount)),
          _sectionTitle(context.tr('customerInfo')),
          _infoRow(
            context.tr('customer'),
            detail.customerName ?? context.tr('notAvailable'),
          ),
          _infoRow('Email', detail.customerEmail ?? context.tr('notAvailable')),
          _infoRow(
            context.tr('phoneNumber'),
            detail.customerPhone ?? context.tr('notAvailable'),
          ),
          _sectionTitle(context.tr('receiver')),
          _infoRow(
            context.tr('receiver'),
            detail.receiverName ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('receiverPhone'),
            detail.receiverPhone ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('address'),
            detail.shippingAddress ?? context.tr('notAvailable'),
          ),
          _sectionTitle(context.tr('payment')),
          _infoRow(
            context.tr('paymentMethod'),
            detail.paymentMethod ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('orderStatus'),
            detail.paymentStatus ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('transactionCode'),
            detail.transactionCode ?? context.tr('notAvailable'),
          ),
          _infoRow(context.tr('paidAt'), _formatDate(detail.paidAt)),
          _sectionTitle(context.tr('shipment')),
          _infoRow(
            context.tr('carrier'),
            detail.carrier ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('trackingNumber'),
            detail.trackingNumber ?? context.tr('notAvailable'),
          ),
          _infoRow(
            context.tr('estimatedDelivery'),
            _formatDate(detail.estimatedDeliveryDate),
          ),
          _infoRow(context.tr('shippedAt'), _formatDate(detail.shippedAt)),
          _infoRow(context.tr('deliveredAt'), _formatDate(detail.deliveredAt)),
          _sectionTitle(context.tr('orderItems')),
          if (detail.items.isEmpty)
            Text(context.tr('noOrderItems'))
          else
            ...detail.items.map(_buildItem),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: locked ? null : () => _editTracking(detail),
            icon: const Icon(Icons.local_shipping),
            label: Text(context.tr('updateTrackingInfo')),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: locked ? null : () => _updateStatus(detail),
            icon: const Icon(Icons.sync),
            label: Text(context.tr('updateShipmentStatus')),
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
            appBar: AppBar(title: Text(context.tr('shipmentDetail'))),
            body: Center(child: Text(context.tr('adminAccessRequired'))),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(context.tr('shipmentDetail'))),
          body: _shipmentId == null
              ? Center(child: Text(context.tr('shipmentIdMissing')))
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

                    final detail = snapshot.data;

                    if (detail == null) {
                      return Center(
                        child: Text(context.tr('shipmentNotFound')),
                      );
                    }

                    return _buildBody(detail);
                  },
                ),
        );
      },
    );
  }

  String _shipmentStatusLabel(String status) {
    return switch (status) {
      'Pending' => context.tr('statusPending'),
      'Preparing' => context.tr('statusPreparing'),
      'Shipped' => context.tr('statusShipped'),
      'InTransit' => context.tr('statusInTransit'),
      'OutForDelivery' => context.tr('statusOutForDelivery'),
      'Delivered' => context.tr('statusDelivered'),
      'Failed' => context.tr('statusFailed'),
      'Returned' => context.tr('statusReturned'),
      _ => status,
    };
  }
}
