import 'package:flutter/material.dart';

import '../../models/refund_request_model.dart';
import '../../services/refund_request_service.dart';
import '../../utils/currency_formatter.dart';
import 'admin_refund_request_detail_screen.dart';

class AdminRefundRequestsScreen extends StatefulWidget {
  const AdminRefundRequestsScreen({super.key});

  @override
  State<AdminRefundRequestsScreen> createState() =>
      _AdminRefundRequestsScreenState();
}

class _AdminRefundRequestsScreenState extends State<AdminRefundRequestsScreen> {
  final _service = RefundRequestService();
  late Future<List<RefundRequestModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getAdminRefundRequests();
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  Color _statusColor(String status) {
    return switch (status.toLowerCase()) {
      'approved' => Colors.blue,
      'refunded' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    };
  }

  void _openDetail(RefundRequestModel request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRefundRequestDetailScreen(
          refundRequestId: request.refundRequestId,
        ),
      ),
    ).then((_) {
      if (mounted) setState(_reload);
    });
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Refund Requests')),
      body: FutureBuilder<List<RefundRequestModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: ElevatedButton(
                onPressed: _refresh,
                child: Text(snapshot.error.toString()),
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No refund requests found.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: InkWell(
                    onTap: () => _openDetail(item),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.requestCode,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.orderCode ??
                                          'Order #${item.orderId}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _statusBadge(item.status),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.customerName ?? item.customerEmail ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.paymentMethod ?? '-'} | ${formatVnd(item.requestedAmount)}',
                          ),
                          const SizedBox(height: 4),
                          Text('${item.bankName} | ${item.bankAccountNumber}'),
                          const SizedBox(height: 4),
                          Text(
                            item.reason,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
