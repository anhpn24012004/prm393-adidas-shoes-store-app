import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
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
  static final _evidenceLinePattern = RegExp(
    r'^(?:Evidence image/video|Ảnh/video bằng chứng)\s*:\s*(.+)$',
    caseSensitive: false,
  );

  static final _uploadsPathPattern = RegExp(
    r'(/uploads/returns/[^\s,]+|https?://[^\s,]+/uploads/returns/[^\s,]+)',
  );

  final _service = ReturnRefundService();
  late TabController _tabController;
  late Future<List<ReturnRequestModel>> _returns;
  late Future<List<RefundModel>> _refunds;
  String _statusFilter = 'All';

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

  Future<bool> _confirm(String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel').toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('confirm').toUpperCase()),
          ),
        ],
      ),
    );
    return result == true;
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

  Future<void> _markReceived(ReturnRequestModel request) async {
    final confirmed = await _confirm(
      'Have you received the returned item from the customer?',
    );
    if (!confirmed) return;
    final note = await _askNote(context.tr('adminNote'));
    if (note == null) return;
    try {
      await _service.markReturnReceived(
        returnRequestId: request.returnRequestId,
        adminNote: note.isEmpty ? null : note,
      );
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _show(error);
    }
  }

  Future<void> _inspect(ReturnRequestModel request) async {
    final noteController = TextEditingController();
    final restockController = TextEditingController(
      text: request.items
          .fold<int>(0, (sum, item) => sum + item.quantity)
          .toString(),
    );
    var isRestockable = true;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Inspection'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    value: isRestockable,
                    title: const Text('Restockable'),
                    onChanged: (value) {
                      setDialogState(() => isRestockable = value);
                    },
                  ),
                  TextField(
                    controller: restockController,
                    enabled: isRestockable,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Restock quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Inspection note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.tr('cancel').toUpperCase()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.tr('confirm').toUpperCase()),
              ),
            ],
          ),
        );
      },
    );

    if (submitted != true) {
      noteController.dispose();
      restockController.dispose();
      return;
    }

    try {
      await _service.inspectReturn(
        returnRequestId: request.returnRequestId,
        isRestockable: isRestockable,
        restockQuantity: isRestockable
            ? int.tryParse(restockController.text.trim()) ?? 0
            : 0,
        inspectionNote: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      noteController.dispose();
      restockController.dispose();
    }
  }

  Future<void> _markRefunded(ReturnRequestModel request) async {
    final confirmed = await _confirm(
      'Have you manually transferred ${formatVnd(request.requestedAmount)} to ${request.bankName} - ${request.bankAccountNumber} - ${request.bankAccountName}?',
    );
    if (!confirmed) return;
    final note = await _askNote('Refund transaction note');
    if (note == null) return;
    try {
      await _service.markReturnRefunded(
        returnRequestId: request.returnRequestId,
        refundTransactionNote: note.isEmpty ? null : note,
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

  List<String> _extractEvidenceUrls(String reason) {
    final urls = <String>[];

    for (final line in reason.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final evidenceMatch = _evidenceLinePattern.firstMatch(trimmed);
      if (evidenceMatch != null) {
        urls.addAll(_parseEvidenceUrlList(evidenceMatch.group(1)!));
        continue;
      }

      for (final match in _uploadsPathPattern.allMatches(trimmed)) {
        final path = match.group(1);
        if (path != null && path.isNotEmpty) {
          urls.add(path);
        }
      }
    }

    return urls.toSet().toList();
  }

  List<String> _parseEvidenceUrlList(String value) {
    return value
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
  }

  String _reasonWithoutEvidence(String reason) {
    final kept = <String>[];

    for (final line in reason.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (_evidenceLinePattern.hasMatch(trimmed)) continue;
      if (_uploadsPathPattern.hasMatch(trimmed) &&
          trimmed.replaceAll(_uploadsPathPattern, '').trim().isEmpty) {
        continue;
      }
      kept.add(line);
    }

    return kept.join('\n').trim();
  }

  String _resolveEvidenceUrl(String path) => AppConfig.resolveImageUrl(path);

  String _fileExtension(String path) {
    final uri = Uri.tryParse(path);
    final target = uri?.path.isNotEmpty == true ? uri!.path : path;
    final dotIndex = target.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return target.substring(dotIndex).toLowerCase();
  }

  bool _isImageEvidence(String path) {
    return const {
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
    }.contains(_fileExtension(path));
  }

  bool _isVideoEvidence(String path) {
    return const {'.mp4', '.mov', '.webm'}.contains(_fileExtension(path));
  }

  Future<void> _openEvidenceUrl(String path) async {
    final url = _resolveEvidenceUrl(path);
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _show('Cannot open evidence file.');
    }
  }

  void _showFullEvidenceImage(String path) {
    final url = _resolveEvidenceUrl(path);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Cannot load evidence image'),
                  );
                },
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSection(List<String> evidencePaths) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Evidence', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...evidencePaths.map(_buildEvidenceItem),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(String rawPath) {
    if (_isImageEvidence(rawPath)) {
      return _buildEvidenceImagePreview(rawPath);
    }

    final label = _isVideoEvidence(rawPath)
        ? 'Open evidence video'
        : 'Open evidence file';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () => _openEvidenceUrl(rawPath),
            icon: Icon(
              _isVideoEvidence(rawPath)
                  ? Icons.videocam_outlined
                  : Icons.attach_file,
            ),
            label: Text(label),
          ),
          const SizedBox(height: 4),
          Text(
            rawPath,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceImagePreview(String rawPath) {
    final fullUrl = _resolveEvidenceUrl(rawPath);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showFullEvidenceImage(rawPath),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Cannot load evidence image'),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            rawPath,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'Pending' => context.tr('statusPending'),
      'Approved' => context.tr('statusApproved'),
      'ReturnShipped' => 'Return shipped',
      'ReturnReceived' => 'Return received',
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
        final filtered = _statusFilter == 'All'
            ? items
            : items.where((item) => item.status == _statusFilter).toList();
        if (items.isEmpty) {
          return Center(child: Text(context.tr('returnsRefundsEmpty')));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildStatusFilters();
            }

            final item = filtered[index - 1];
            return _buildReturnCard(item);
          },
        );
      },
    );
  }

  Widget _buildStatusFilters() {
    final statuses = [
      'All',
      'Pending',
      'Approved',
      'ReturnShipped',
      'ReturnReceived',
      'Refunded',
      'Rejected',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses
            .map(
              (status) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(status == 'All' ? 'All' : _statusLabel(status)),
                  selected: _statusFilter == status,
                  onSelected: (_) => setState(() => _statusFilter = status),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildReturnCard(ReturnRequestModel item) {
    final evidenceUrls = _extractEvidenceUrls(item.reason);
    final displayReason = _reasonWithoutEvidence(item.reason);

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          '${item.requestCode.isEmpty ? '#${item.returnRequestId}' : item.requestCode} - ${item.orderCode.isEmpty ? 'Order #${item.orderId}' : item.orderCode}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${item.customerName ?? context.tr('notAvailable')} - ${_statusLabel(item.status)}\n${formatVnd(item.requestedAmount)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          _line(
            'Customer',
            '${item.customerName ?? ''} ${item.customerPhone ?? ''}',
          ),
          _line(
            'Payment',
            '${item.paymentMethod ?? ''} - ${item.paymentStatus ?? ''}',
          ),
          if (displayReason.isNotEmpty) _line('Reason', displayReason),
          if (item.customerNote?.isNotEmpty == true)
            _line('Customer note', item.customerNote!),
          if (evidenceUrls.isNotEmpty) _buildEvidenceSection(evidenceUrls),
          _line(
            'Bank',
            '${item.bankName} - ${item.bankAccountNumber} - ${item.bankAccountName}',
          ),
          const SizedBox(height: 8),
          ...item.items.map(
            (returnItem) => _line(
              returnItem.productName,
              '${returnItem.quantity} x ${formatVnd(returnItem.unitPrice)} = ${formatVnd(returnItem.refundAmount)}',
            ),
          ),
          if (item.returnTrackingCode?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _line('Return carrier', item.returnCarrier ?? ''),
            _line('Tracking code', item.returnTrackingCode!),
            if (item.returnShipmentNote?.isNotEmpty == true)
              _line('Return note', item.returnShipmentNote!),
          ],
          if (item.inspectionNote?.isNotEmpty == true)
            _line('Inspection', item.inspectionNote!),
          if (item.adminNote?.isNotEmpty == true)
            _line('Admin note', item.adminNote!),
          const SizedBox(height: 12),
          _buildReturnActions(item),
        ],
      ),
    );
  }

  Widget _buildReturnActions(ReturnRequestModel item) {
    if (item.status == 'Pending') {
      return Row(
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
      );
    }

    if (item.status == 'Approved' || item.status == 'ReturnShipped') {
      return ElevatedButton(
        onPressed: () => _markReceived(item),
        child: const Text('MARK RETURN AS RECEIVED'),
      );
    }

    if (item.status == 'ReturnReceived') {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton(
            onPressed: () => _inspect(item),
            child: const Text('INSPECT'),
          ),
          ElevatedButton(
            onPressed: item.isRestockable == true
                ? () => _markRefunded(item)
                : null,
            child: const Text('MARK AS REFUNDED'),
          ),
          OutlinedButton(
            onPressed: () => _review(item, false),
            child: const Text('REJECT'),
          ),
        ],
      );
    }

    return const Align(
      alignment: Alignment.centerLeft,
      child: Text('Readonly'),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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
