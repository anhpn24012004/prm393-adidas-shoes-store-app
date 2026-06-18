import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../models/return_refund_model.dart';
import '../../services/return_refund_service.dart';
import '../../theme/app_theme.dart';

class RefundStatusScreen extends StatefulWidget {
  const RefundStatusScreen({super.key});

  @override
  State<RefundStatusScreen> createState() => _RefundStatusScreenState();
}

class _RefundStatusScreenState extends State<RefundStatusScreen> {
  final _service = ReturnRefundService();
  late Future<List<ReturnRequestModel>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getUserReturns(AppConfig.currentUserId);
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
      'approved' => context.tr('statusApproved'),
      'refunded' => context.tr('statusRefunded'),
      'rejected' => context.tr('statusRejected'),
      _ => context.tr('statusPending'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('returnsRefunds').toUpperCase())),
      body: FutureBuilder<List<ReturnRequestModel>>(
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
            return Center(child: Text(context.tr('returnsRefundsEmpty')));
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
                                '${context.tr('order').toUpperCase()} #${request.orderId}',
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
                        if (request.adminNote?.isNotEmpty == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${context.tr('adminNote')}: ${request.adminNote}',
                            style: const TextStyle(color: AppColors.muted),
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
