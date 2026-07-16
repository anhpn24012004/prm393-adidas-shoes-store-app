import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/refund_request_service.dart';
import '../../services/return_refund_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';

class RefundRequestScreen extends StatefulWidget {
  final int? orderId;

  const RefundRequestScreen({super.key, this.orderId});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  final _orderService = OrderService();
  final _refundService = RefundRequestService();
  final _returnService = ReturnRefundService();
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _detailsController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _requestedAmountController = TextEditingController();
  final _customerNoteController = TextEditingController();

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
    _reasonController.dispose();
    _detailsController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankAccountNameController.dispose();
    _requestedAmountController.dispose();
    _customerNoteController.dispose();
    super.dispose();
  }

  Future<void> _load(int orderId) async {
    try {
      final order = await _orderService.getOrderDetail(orderId);

      if (!mounted) return;

      setState(() {
        _order = order;
        _requestedAmountController.text = order.finalAmount.toStringAsFixed(2);
        for (final item in order.items) {
          _selectedItems[item.orderItemId] = true;
          _quantities[item.orderItemId] = item.quantity;
        }
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage(error);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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

  bool _isOnlinePaidEligible(OrderDetail order) {
    final paymentMethod = order.payment.paymentMethod?.trim().toUpperCase();
    final paymentStatus = order.payment.paymentStatus?.trim();
    final hasShipment =
        order.shipmentId != null || order.shipmentStatus != null;

    return !hasShipment &&
        (order.status == 'Paid' || order.status == 'Processing') &&
        (paymentMethod == 'SEPAY' ||
            paymentMethod == 'VNPAY' ||
            paymentMethod == 'PAYPAL') &&
        paymentStatus == 'Success';
  }

  bool _isReturnEligible(OrderDetail order) {
    return (order.status == 'Delivered' || order.status == 'Completed') &&
        order.payment.paymentStatus == 'Success' &&
        order.items.isNotEmpty;
  }

  bool _hasActiveRefundRequest(OrderDetail order) {
    final status = order.latestRefundRequestStatus;
    return status == 'Pending' || status == 'Approved';
  }

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

  String? _supportMessage(OrderDetail order) {
    if (_hasActiveRefundRequest(order)) {
      return 'A refund request already exists for this order.';
    }

    if (order.shipmentId != null || order.shipmentStatus == 'Shipping') {
      return 'This order is already being shipped. Please contact support for cancellation or refund.';
    }

    if (order.status == 'Delivered' || order.status == 'Completed') {
      return 'This order is already delivered. Please contact support for refund assistance.';
    }

    return null;
  }

  String _buildReturnReasonText() {
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

  Future<void> _submitRefundRequest() async {
    final order = _order;
    if (order == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await _refundService.createRefundRequest(
        orderId: order.orderId,
        reason: _reasonController.text.trim(),
        requestedAmount: double.parse(
          _requestedAmountController.text.trim().replaceAll(',', ''),
        ),
        bankName: _bankNameController.text.trim(),
        bankAccountNumber: _bankAccountNumberController.text.trim(),
        bankAccountName: _bankAccountNameController.text.trim(),
        customerNote: _customerNoteController.text.trim().isEmpty
            ? null
            : _customerNoteController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Refund request submitted. Admin will review and process the refund manually.',
          ),
        ),
      );

      Navigator.pushReplacementNamed(context, '/refund-status');
    } catch (error) {
      _showMessage(error);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _submitReturnRequest() async {
    final order = _order;
    if (order == null || _selectedReason == null) {
      _showMessage(context.tr('selectReturnReasonPrompt'));
      return;
    }

    final bankName = _bankNameController.text.trim();
    final bankAccountNumber = _bankAccountNumberController.text.trim();
    final bankAccountName = _bankAccountNameController.text.trim();
    if (bankName.isEmpty ||
        bankAccountNumber.isEmpty ||
        bankAccountName.isEmpty) {
      _showMessage('Bank name, account number, and account name are required.');
      return;
    }

    final items = order.items
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
      _showMessage('Select at least one item to return.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final evidenceUrls = await _uploadEvidenceFiles();
      final reasonParts = [_buildReturnReasonText()];

      if (evidenceUrls.isNotEmpty) {
        reasonParts.add(
          '${context.tr('returnEvidence')}: ${evidenceUrls.join(', ')}',
        );
      }

      await _returnService.createReturn(
        orderId: order.orderId,
        reason: reasonParts.join('\n'),
        customerNote: _detailsController.text.trim().isEmpty
            ? null
            : _detailsController.text.trim(),
        bankName: bankName,
        bankAccountNumber: bankAccountNumber,
        bankAccountName: bankAccountName,
        items: items,
      );

      if (!mounted) return;
      _showMessage('Return request submitted. Please wait for admin approval.');
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showMessage(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(Object message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  Widget _buildHeader(OrderDetail order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            order.orderCode,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text('Order status: ${_statusLabel(order.status)}'),
          Text('Payment: ${order.payment.paymentStatus ?? 'Not available'}'),
          Text('Final amount: ${formatVnd(order.finalAmount)}'),
        ],
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
                        value: quantity.clamp(1, item.quantity).toInt(),
                        items:
                            List.generate(item.quantity, (index) => index + 1)
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

  Widget _buildRefundForm(OrderDetail order) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Refund request'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Reason is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildRequiredTextField(
            controller: _bankNameController,
            label: 'Bank name',
            errorText: 'Bank name is required',
          ),
          const SizedBox(height: 12),
          _buildRequiredTextField(
            controller: _bankAccountNumberController,
            label: 'Bank account number',
            errorText: 'Bank account number is required',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildRequiredTextField(
            controller: _bankAccountNameController,
            label: 'Bank account name',
            errorText: 'Bank account name is required',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _requestedAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Requested amount',
              helperText: 'Max ${formatVnd(order.finalAmount)}',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              final amount = double.tryParse(
                value?.trim().replaceAll(',', '') ?? '',
              );

              if (amount == null || amount <= 0) {
                return 'Requested amount must be greater than 0';
              }

              if (amount > order.finalAmount) {
                return 'Requested amount cannot exceed the final amount';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _customerNoteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Customer note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitRefundRequest,
              child: Text(
                _submitting ? 'Submitting...' : 'Submit refund request',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnForm(OrderDetail order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                (reason) =>
                    DropdownMenuItem(value: reason, child: Text(reason)),
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
        _buildPlainTextField(
          controller: _bankNameController,
          label: 'Bank name',
        ),
        const SizedBox(height: 14),
        _buildPlainTextField(
          controller: _bankAccountNumberController,
          label: 'Bank account number',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 14),
        _buildPlainTextField(
          controller: _bankAccountNameController,
          label: 'Bank account name',
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 14),
        _buildEvidencePicker(),
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: _submitting ? null : _submitReturnRequest,
          child: Text(
            (_submitting
                    ? context.tr('submitting')
                    : context.tr('submitReturnRequest'))
                .toUpperCase(),
          ),
        ),
      ],
    );
  }

  Widget _buildRequiredTextField({
    required TextEditingController controller,
    required String label,
    required String errorText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return errorText;
        }
        return null;
      },
    );
  }

  Widget _buildPlainTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      enabled: !_submitting,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      appBar: AppBar(title: const Text('Request cancellation / refund')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
          ? const Center(child: Text('Order not found.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(order),
                const SizedBox(height: 16),
                if (_hasActiveRefundRequest(order)) ...[
                  const Text(
                    'A refund request is already pending or approved for this order.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/refund-status',
                    ),
                    child: const Text('View refund requests'),
                  ),
                ] else if (_isOnlinePaidEligible(order)) ...[
                  _buildRefundForm(order),
                ] else if (_isReturnEligible(order)) ...[
                  _buildReturnForm(order),
                ] else ...[
                  Text(
                    _supportMessage(order) ??
                        'This order is not eligible for direct cancellation.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}
