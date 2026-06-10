import 'package:flutter/material.dart';

import '../../models/shipment_model.dart';
import '../../services/auth_storage.dart';
import '../../services/shipment_service.dart';
import 'admin_shipment_detail_screen.dart';
import 'admin_shipment_form_screen.dart';

class AdminShipmentListScreen extends StatefulWidget {
  const AdminShipmentListScreen({super.key});

  @override
  State<AdminShipmentListScreen> createState() =>
      _AdminShipmentListScreenState();
}

class _AdminShipmentListScreenState extends State<AdminShipmentListScreen> {
  final ShipmentService _shipmentService = ShipmentService();
  final AuthStorage _authStorage = AuthStorage();
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _filterStatuses = [
    'All',
    'Pending',
    'Preparing',
    'Shipped',
    'InTransit',
    'OutForDelivery',
    'Delivered',
    'Failed',
    'Returned',
  ];

  late Future<List<ShipmentSummary>> _shipmentsFuture;
  late Future<bool> _isAdminFuture;
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _isAdminFuture = _authStorage.isAdmin();
    _loadShipments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadShipments() {
    _shipmentsFuture = _shipmentService.getAdminShipments();
  }

  String _formatMoney(double? amount) {
    if (amount == null) return 'N/A';
    return '${amount.toStringAsFixed(0)} VND';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  List<ShipmentSummary> _applyFilters(List<ShipmentSummary> shipments) {
    final keyword = _searchController.text.trim().toLowerCase();

    return shipments.where((shipment) {
      final matchesStatus =
          _selectedStatus == 'All' ||
          shipment.shipmentStatus == _selectedStatus;
      final haystack = [
        shipment.orderCode,
        shipment.customerName,
        shipment.receiverName,
        shipment.receiverPhone,
        shipment.carrier,
        shipment.trackingNumber,
      ].whereType<String>().join(' ').toLowerCase();
      final matchesKeyword = keyword.isEmpty || haystack.contains(keyword);

      return matchesStatus && matchesKeyword;
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadShipments();
    });
  }

  Future<void> _openCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminShipmentFormScreen(createMode: true),
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Future<void> _openDetail(ShipmentSummary shipment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminShipmentDetailScreen(shipmentId: shipment.shipmentId),
      ),
    );

    if (result == true) {
      await _refresh();
    }
  }

  Widget _buildShipmentCard(ShipmentSummary shipment) {
    return Card(
      child: ListTile(
        onTap: () => _openDetail(shipment),
        title: Text(
          shipment.orderCode ?? 'Shipment',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${shipment.customerName ?? 'N/A'}\n'
          'Receiver: ${shipment.receiverName ?? 'N/A'} - ${shipment.receiverPhone ?? 'N/A'}\n'
          'Carrier: ${shipment.carrier ?? 'N/A'}  Tracking: ${shipment.trackingNumber ?? 'N/A'}\n'
          'Shipment: ${shipment.shipmentStatus ?? 'N/A'}  Order: ${shipment.orderStatus ?? 'N/A'}\n'
          'Payment: ${shipment.paymentStatus ?? 'N/A'}  ETA: ${_formatDate(shipment.estimatedDeliveryDate)}',
        ),
        isThreeLine: false,
        trailing: Text(
          _formatMoney(shipment.finalAmount),
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<ShipmentSummary>>(
      future: _shipmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                  ),
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

        final shipments = _applyFilters(snapshot.data ?? []);

        if (shipments.isEmpty) {
          return const Center(child: Text('No shipments found'));
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shipments.length,
            itemBuilder: (context, index) {
              return _buildShipmentCard(shipments[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search shipments...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _filterStatuses.map((status) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (_) {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data != true) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shipment Management')),
            body: const Center(child: Text('Admin access required')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Shipment Management')),
          body: Column(
            children: [
              _buildFilters(),
              Expanded(child: _buildBody()),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreate,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
