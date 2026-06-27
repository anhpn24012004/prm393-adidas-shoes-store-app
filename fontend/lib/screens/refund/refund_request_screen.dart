import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/return_refund_service.dart';
import '../../theme/app_theme.dart';

class RefundRequestScreen extends StatefulWidget {
  final int? orderId;

  const RefundRequestScreen({super.key, this.orderId});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _orderService = OrderService();
  final _returnService = ReturnRefundService();
  final _imagePicker = ImagePicker();
  final _detailsController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();

  OrderDetail? _order;
  String? _selectedReason;
  final Map<int, bool> _selectedItems = {};
  final Map<int, int> _quantities = {};
  final List<XFile> _evidenceFiles = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loading || _order != null) return;
    final argument = ModalRoute.of(context)?.settings.arguments;
    final orderId = widget.orderId ?? (argument is int ? argument : null);
    if (orderId == null) {
      setState(() => _loading = false);
      return;
    }
    _load(orderId);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _bankNameController.dispose();
    _bankNumberController.dispose();
    _bankAccountNameController.dispose();
    super.dispose();
  }

  Future<void> _load(int orderId) async {
    try {
      final order = await _orderService.getOrderDetail(orderId);
      if (mounted) {
        setState(() {
          _order = order;
          for (final item in order.items) {
            _selectedItems[item.orderItemId] = true;
            _quantities[item.orderItemId] = item.quantity;
          }
        });
      }
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<String> get _returnReasons => [
        context.tr('returnReasonDefective'),
        context.tr('returnReasonWrongDescription'),
        context.tr('returnReasonWrongItem'),
        context.tr('returnReasonMissingItem'),
        context.tr('returnReasonDamagedPackage'),
        context.tr('returnReasonChangedMind'),
        context.tr('returnReasonOther'),
      ];

  String _statusLabel(String status) {
    return switch (status) {
      'PendingPayment' => context.tr('statusPendingPayment'),
      'Paid' => context.tr('statusPaid'),
      'Processing' => context.tr('statusProcessing'),
      'Shipping' => context.tr('statusShipping'),
      'Delivered' => context.tr('statusDelivered'),
      'Cancelled' => context.tr('statusCancelled'),
      'Completed' => context.tr('statusCompleted'),
      _ => status,
    };
  }

  String _buildReasonText() {
    final parts = <String>[_selectedReason ?? ''];
    final details = _detailsController.text.trim();

    if (details.isNotEmpty) {
      parts.add('${context.tr('returnDetails')}: $details');
    }

    return parts.join('\n');
  }

  Future<void> _pickImages() async {
    final files = await _imagePicker.pickMultiImage();

    if (files.isEmpty || !mounted) return;

    setState(() {
      _evidenceFiles.addAll(files);
    });
  }

  Future<void> _pickVideo() async {
    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (file == null || !mounted) return;

    setState(() {
      _evidenceFiles.add(file);
    });
  }

  Future<void> _capturePhoto() async {
    final file = await _imagePicker.pickImage(source: ImageSource.camera);

    if (file == null || !mounted) return;

    setState(() {
      _evidenceFiles.add(file);
    });
  }

  Future<List<String>> _uploadEvidenceFiles() async {
    final urls = <String>[];

    for (final file in _evidenceFiles) {
      final bytes = await file.readAsBytes();
      final url = await _returnService.uploadEvidence(
        bytes: bytes,
        fileName: file.name,
      );

      if (url.isNotEmpty) {
        urls.add(url);
      }
    }

    return urls;
  }

  Future<void> _submit() async {
    if (_order == null || _selectedReason == null) {
      _show(context.tr('selectReturnReasonPrompt'));
      return;
    }

    final bankName = _bankNameController.text.trim();
    final bankNumber = _bankNumberController.text.trim();
    final bankAccountName = _bankAccountNameController.text.trim();
    if (bankName.isEmpty || bankNumber.isEmpty || bankAccountName.isEmpty) {
      _show('Bank name, account number, and account name are required.');
      return;
    }

    final items = _order!.items
        .where((item) => _selectedItems[item.orderItemId] == true)
        .map(
          (item) => {
            'orderItemId': item.orderItemId,
            'quantity': _quantities[item.orderItemId] ?? 0,
            'reason': _selectedReason,
          },
        )
        .where((item) => (item['quantity'] as int) > 0)
        .toList();

    if (items.isEmpty) {
      _show('Select at least one item to return.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final evidenceUrls = await _uploadEvidenceFiles();
      final reasonParts = [_buildReasonText()];

      if (evidenceUrls.isNotEmpty) {
        reasonParts.add(
          '${context.tr('returnEvidence')}: ${evidenceUrls.join(', ')}',
        );
      }

      final reason = reasonParts.join('\n');

      await _returnService.createReturn(
        orderId: _order!.orderId,
        reason: reason,
        customerNote: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        bankName: bankName,
        bankAccountNumber: bankNumber,
        bankAccountName: bankAccountName,
        items: items,
      );
      if (!mounted) return;
      _show('Return request submitted. Please wait for admin approval.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(Object message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  Widget _buildOrderItems(OrderDetail order) {
    return Column(
      children: order.items.map((item) {
        final selected = _selectedItems[item.orderItemId] ?? false;
        final quantity = _quantities[item.orderItemId] ?? item.quantity;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: selected,
                      onChanged: _submitting
                          ? null
                          : (value) {
                              setState(() {
                                _selectedItems[item.orderItemId] =
                                    value ?? false;
                              });
                            },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${context.tr('productSize')}: ${item.size}  '
                            '${context.tr('productColor')}: ${item.color}',
                          ),
                          Text('${context.tr('quantity')}: ${item.quantity}'),
                        ],
                      ),
                    ),
                    const Icon(Icons.assignment_return_outlined),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Return quantity'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: quantity.clamp(1, item.quantity),
                        items: List.generate(item.quantity, (index) => index + 1)
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: _submitting
                            ? null
                            : (value) {
                                if (value == null) return;
                                setState(() {
                                  _quantities[item.orderItemId] = value;
                                });
                              },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEvidencePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('returnEvidence'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: _submitting ? null : _pickImages,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(context.tr('choosePhotos')),
            ),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _capturePhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(context.tr('takePhoto')),
            ),
            OutlinedButton.icon(
              onPressed: _submitting ? null : _pickVideo,
              icon: const Icon(Icons.video_library_outlined),
              label: Text(context.tr('chooseVideo')),
            ),
          ],
        ),
        if (_evidenceFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _evidenceFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;

              return Chip(
                avatar: Icon(
                  _isVideo(file.name)
                      ? Icons.videocam_outlined
                      : Icons.image_outlined,
                  size: 18,
                ),
                label: Text(file.name),
                onDeleted: _submitting
                    ? null
                    : () {
                        setState(() {
                          _evidenceFiles.removeAt(index);
                        });
                      },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  bool _isVideo(String fileName) {
    final lowerName = fileName.toLowerCase();
    return lowerName.endsWith('.mp4') ||
        lowerName.endsWith('.mov') ||
        lowerName.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('requestReturn').toUpperCase())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(child: Text(context.tr('openReturnFromOrder')))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      context.tr('returnWholeOrder').toUpperCase(),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.orderCode} - ${_statusLabel(order.status)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 22),
                    _buildOrderItems(order),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      items: _returnReasons
                          .map(
                            (reason) => DropdownMenuItem(
                              value: reason,
                              child: Text(reason),
                            ),
                          )
                          .toList(),
                      onChanged: _submitting
                          ? null
                          : (value) => setState(() {
                                _selectedReason = value;
                              }),
                      decoration: InputDecoration(
                        labelText: context.tr('returnReason'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _detailsController,
                      enabled: !_submitting,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: context.tr('returnDetailsOptional'),
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bankNameController,
                      enabled: !_submitting,
                      decoration: const InputDecoration(
                        labelText: 'Bank name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bankNumberController,
                      enabled: !_submitting,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Bank account number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bankAccountNameController,
                      enabled: !_submitting,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Bank account name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildEvidencePicker(),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(
                        (_submitting
                                ? context.tr('submitting')
                                : context.tr('submitReturnRequest'))
                            .toUpperCase(),
                      ),
                    ),
                  ],
                ),
    );
  }
}
