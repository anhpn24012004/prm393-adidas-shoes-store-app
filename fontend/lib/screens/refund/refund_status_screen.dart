import 'package:flutter/material.dart';

import '../../models/refund_request_model.dart';
import '../../services/refund_request_service.dart';
import '../../utils/currency_formatter.dart';

class RefundStatusScreen extends StatefulWidget {
  const RefundStatusScreen({super.key});

  @override
  State<RefundStatusScreen> createState() => _RefundStatusScreenState();
}

class _RefundStatusScreenState extends State<RefundStatusScreen> {
  final _service = RefundRequestService();
  late Future<List<RefundRequestModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getMyRefundRequests();
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

  String _statusLabel(String status) {
    return switch (status.toLowerCase()) {
      'approved' => 'Approved',
      'refunded' => 'Refunded',
      'rejected' => 'Rejected',
      _ => 'Pending',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My refund requests')),
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
                child: Text(
                  snapshot.error.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            );
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text('No refund requests yet.'));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${request.requestCode} - Order #${request.orderId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              color: _statusColor(request.status),
                              child: Text(
                                _statusLabel(request.status).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(request.reason),
                        const SizedBox(height: 6),
                        Text('Requested amount: ${formatVnd(request.requestedAmount)}'),
                        if (request.bankName.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${request.bankName} - ${request.bankAccountName} (${request.bankAccountNumber})',
                          ),
                        ],
                        if (request.adminNote?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Admin note: ${request.adminNote}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
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
