import 'package:flutter/material.dart';

import '../../models/return_refund_model.dart';
import '../../services/return_refund_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class AdminReturnsRefundsScreen extends StatefulWidget {
  const AdminReturnsRefundsScreen({super.key});

  @override
  State<AdminReturnsRefundsScreen> createState() =>
      _AdminReturnsRefundsScreenState();
}

class _AdminReturnsRefundsScreenState extends State<AdminReturnsRefundsScreen>
    with SingleTickerProviderStateMixin {
  final _service = ReturnRefundService();
  late TabController _tabController;
  late Future<List<ReturnRequestModel>> _returns;
  late Future<List<RefundModel>> _refunds;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reload();
  }

  void _reload() {
    _returns = _service.getAllReturns();
    _refunds = _service.getAllRefunds();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String?> _askNote(String title) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Admin note'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _review(ReturnRequestModel request, bool approve) async {
    final note = await _askNote(approve ? 'Approve return' : 'Reject return');
    if (note == null) return;
    try {
      await _service.reviewReturn(
        returnRequestId: request.returnRequestId,
        approve: approve,
        adminNote: note.isEmpty ? null : note,
      );
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _show(error);
    }
  }

  Future<void> _complete(RefundModel refund) async {
    final code = await _askNote('Complete refund: transaction code');
    if (code == null) return;
    try {
      await _service.completeRefund(refund.refundId, code);
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _show(error);
    }
  }

  void _show(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RETURNS & REFUNDS'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RETURN REQUESTS'),
            Tab(text: 'REFUNDS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReturns(), _buildRefunds()],
      ),
    );
  }

  Widget _buildReturns() {
    return FutureBuilder<List<ReturnRequestModel>>(
      future: _returns,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final items = snapshot.data ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RETURN #${item.returnRequestId} • ORDER #${item.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(item.reason),
                    Text(
                      item.status,
                      style: const TextStyle(
                        color: AppColors.blue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.status == 'Pending') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _review(item, false),
                              child: const Text('REJECT'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _review(item, true),
                              child: const Text('APPROVE'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRefunds() {
    return FutureBuilder<List<RefundModel>>(
      future: _refunds,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final items = snapshot.data ?? [];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  'REFUND #${item.refundId}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  'Order #${item.orderId}\n${item.status} • ${item.paymentMethod ?? 'N/A'}',
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatVnd(item.amount),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    if (item.status == 'Pending')
                      TextButton(
                        onPressed: () => _complete(item),
                        child: const Text('COMPLETE'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
