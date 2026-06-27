import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/refund_request_model.dart';
import '../../services/refund_request_service.dart';
import '../../utils/currency_formatter.dart';

class AdminRefundRequestDetailScreen extends StatefulWidget {
  final int refundRequestId;

  const AdminRefundRequestDetailScreen({
    super.key,
    required this.refundRequestId,
  });

  @override
  State<AdminRefundRequestDetailScreen> createState() =>
      _AdminRefundRequestDetailScreenState();
}

class _AdminRefundRequestDetailScreenState
    extends State<AdminRefundRequestDetailScreen> {
  final _service = RefundRequestService();
  late Future<RefundRequestModel> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getAdminRefundRequestById(widget.refundRequestId);
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

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  String _joinNonEmpty(List<String?> values) {
    return values
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' / ');
  }

  Future<void> _copy(String value) async {
    if (value.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<String?> _askText({
    required String title,
    required String label,
    String? initialValue,
    bool requiredText = false,
    String confirmLabel = 'CONFIRM',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: label,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (requiredText && value.isEmpty) {
                return;
              }
              Navigator.pop(context, value);
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _approve(RefundRequestModel request) async {
    final note = await _askText(
      title: 'Approve refund request',
      label: 'Admin note (optional)',
      initialValue: request.adminNote,
    );
    if (note == null) return;

    await _runAction(() async {
      await _service.approveRequest(
        request.refundRequestId,
        adminNote: note.isEmpty ? null : note,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Refund request approved. Please transfer the refund manually, then mark it as refunded.',
            ),
          ),
        );
      }
    });
  }

  Future<void> _reject(RefundRequestModel request) async {
    final note = await _askText(
      title: 'Reject refund request',
      label: 'Reason / admin note',
      initialValue: request.adminNote,
      requiredText: true,
    );
    if (note == null || note.trim().isEmpty) return;

    await _runAction(() async {
      await _service.rejectRequest(
        request.refundRequestId,
        adminNote: note.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund request rejected.')),
        );
      }
    });
  }

  Future<void> _markRefunded(RefundRequestModel request) async {
    if (request.status != 'Approved') return;

    final noteController = TextEditingController(
      text: request.refundTransactionNote ?? '',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as refunded'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Have you manually transferred ${formatVnd(request.requestedAmount)} to ${request.bankName} - ${request.bankAccountNumber} - ${request.bankAccountName}?',
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Refund transaction note (optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
    final note = noteController.text.trim();
    noteController.dispose();

    if (confirmed != true) return;

    await _runAction(() async {
      final updated = await _service.markAsRefunded(
        request.refundRequestId,
        refundTransactionNote: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      if (updated.hasShipment) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This order already has shipment. Handle return logistics before restocking.',
            ),
          ),
        );
      }
    });
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
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
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refund Request Detail')),
      body: FutureBuilder<RefundRequestModel>(
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

          final request = snapshot.data!;
          final status = request.status;
          final isPending = status == 'Pending';
          final isApproved = status == 'Approved';
          final isRejected = status == 'Rejected';
          final isRefunded = status == 'Refunded';
          final canApproveReject = isPending;
          final canMarkRefunded = isApproved;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        request.requestCode,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    _statusBadge(request.status),
                  ],
                ),
                const SizedBox(height: 20),
                _section('Request', [
                  _line('Request code', request.requestCode),
                  _line('Order code', request.orderCode ?? '-'),
                  _line('Customer', _joinNonEmpty([
                    request.customerName,
                    request.customerEmail,
                  ])),
                  _line('Payment method', request.paymentMethod ?? '-'),
                  _line('Payment status', request.paymentStatus ?? '-'),
                  _line('Order status', request.orderStatus ?? '-'),
                  _copyableLine('Requested amount', formatVnd(request.requestedAmount)),
                ]),
                _section('Bank', [
                  _copyableLine('Bank name', request.bankName),
                  _copyableLine('Bank account number', request.bankAccountNumber),
                  _copyableLine('Bank account name', request.bankAccountName),
                ]),
                _section('Notes', [
                  _line('Reason', request.reason),
                  _line('Customer note', request.customerNote ?? '-'),
                  _line('Admin note', request.adminNote ?? '-'),
                  _line(
                    'Refund transaction note',
                    request.refundTransactionNote ?? '-',
                  ),
                ]),
                _section('Timeline', [
                  _line('Status', request.status),
                  _line('Created at', _formatDate(request.createdAt)),
                  _line('Approved at', _formatDate(request.approvedAt)),
                  _line('Rejected at', _formatDate(request.rejectedAt)),
                  _line('Refunded at', _formatDate(request.refundedAt)),
                  _line(
                    'Processed by admin ID',
                    request.processedByAdminId?.toString() ?? '-',
                  ),
                  _line(
                    'Processed by admin',
                    _joinNonEmpty([
                      request.processedByAdminName,
                      request.processedByAdminEmail,
                    ]),
                  ),
                ]),
                if (request.hasShipment) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: const Text(
                      'This order already has shipment. Handle return logistics before restocking.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (canApproveReject)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: _busy ? null : () => _reject(request),
                        child: const Text('REJECT'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _busy ? null : () => _approve(request),
                        child: const Text('APPROVE'),
                      ),
                    ],
                  )
                else if (canMarkRefunded)
                  ElevatedButton(
                    onPressed: _busy ? null : () => _markRefunded(request),
                    child: Text(_busy ? 'PROCESSING...' : 'MARK AS REFUNDED'),
                  )
                else if (isRejected || isRefunded)
                  const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _copyIconButton(String value) {
    return IconButton(
      onPressed: value.trim().isEmpty ? null : () => _copy(value),
      icon: const Icon(Icons.copy),
      tooltip: 'Copy',
    );
  }

  Widget _copyableLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(value.isEmpty ? '-' : value)),
                _copyIconButton(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
