import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/refund_request_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _requestedAmountController = TextEditingController();
  final _customerNoteController = TextEditingController();

  OrderDetail? _order;
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

  bool _isOnlinePaidEligible(OrderDetail order) {
    final paymentMethod = order.payment.paymentMethod?.trim().toUpperCase();
    final paymentStatus = order.payment.paymentStatus?.trim();
    final hasShipment = order.shipmentId != null || order.shipmentStatus != null;

    return !hasShipment &&
        (order.status == 'Paid' || order.status == 'Processing') &&
        (paymentMethod == 'SEPAY' ||
            paymentMethod == 'VNPAY' ||
            paymentMethod == 'PAYPAL') &&
        paymentStatus == 'Success';
  }

  bool _hasActiveRefundRequest(OrderDetail order) {
    final status = order.latestRefundRequestStatus;
    return status == 'Pending' || status == 'Approved';
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

  void _showMessage(Object message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  Future<void> _submit() async {
    final order = _order;
    if (order == null) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      await _refundService.createRefundRequest(
        orderId: order.orderId,
        reason: _reasonController.text.trim(),
        requestedAmount: double.parse(_requestedAmountController.text.trim()),
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
          Text('Order status: ${order.status}'),
          Text('Payment: ${order.payment.paymentStatus ?? 'Not available'}'),
          Text('Final amount: ${formatVnd(order.finalAmount)}'),
        ],
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
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/refund-status'),
                        child: const Text('View refund requests'),
                      ),
                    ] else if (_isOnlinePaidEligible(order)) ...[
                      Form(
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
                            TextFormField(
                              controller: _bankNameController,
                              decoration: const InputDecoration(
                                labelText: 'Bank name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Bank name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bankAccountNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Bank account number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Bank account number is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bankAccountNameController,
                              decoration: const InputDecoration(
                                labelText: 'Bank account name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Bank account name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _requestedAmountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Requested amount',
                                helperText:
                                    'Max ${formatVnd(order.finalAmount)}',
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
                                onPressed: _submitting ? null : _submit,
                                child: Text(
                                  _submitting
                                      ? 'Submitting...'
                                      : 'Submit refund request',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
