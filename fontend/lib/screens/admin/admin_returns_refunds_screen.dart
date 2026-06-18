import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
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
          decoration: InputDecoration(labelText: context.tr('adminNote')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel').toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(context.tr('confirm').toUpperCase()),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _review(ReturnRequestModel request, bool approve) async {
    final note = await _askNote(
      approve ? context.tr('approveReturn') : context.tr('rejectReturn'),
    );
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
    final code = await _askNote(context.tr('completeRefundTransactionCode'));
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

  String _statusLabel(String status) {
    return switch (status) {
      'Pending' => context.tr('statusPending'),
      'Approved' => context.tr('statusApproved'),
      'Refunded' => context.tr('statusRefunded'),
      'Rejected' => context.tr('statusRejected'),
      'Completed' => context.tr('statusCompleted'),
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('returnsRefunds')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.tr('returnRequests').toUpperCase()),
            Tab(text: context.tr('refunds').toUpperCase()),
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
        if (items.isEmpty) {
          return Center(child: Text(context.tr('returnsRefundsEmpty')));
        }
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
                      '${context.tr('returnRequest')} #${item.returnRequestId} - ${context.tr('order')} #${item.orderId}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(item.reason),
                    Text(
                      _statusLabel(item.status),
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
                              child: Text(context.tr('reject').toUpperCase()),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _review(item, true),
                              child: Text(context.tr('approve').toUpperCase()),
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
        if (items.isEmpty) {
          return Center(child: Text(context.tr('refundsEmpty')));
        }
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
                  '${context.tr('refund')} #${item.refundId}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${context.tr('order')} #${item.orderId}\n'
                  '${_statusLabel(item.status)} - ${item.paymentMethod ?? context.tr('notAvailable')}',
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
                        child: Text(context.tr('complete').toUpperCase()),
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
