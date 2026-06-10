import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final TextEditingController _addressIdController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _paymentMethod = 'COD';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final addressId = int.tryParse(_addressIdController.text.trim());

    if (addressId == null || addressId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid address ID')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final order = await _orderService.createOrder(
        addressId: addressId,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (!mounted) return;

      if (_paymentMethod == 'VNPAY') {
        await _handleVnPay(order);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created successfully')),
      );

      Navigator.pushReplacementNamed(
        context,
        '/order-detail',
        arguments: order.orderId,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleVnPay(OrderDetail order) async {
    try {
      final response = await _orderService.createVnPayPayment(order.orderId);
      final uri = Uri.tryParse(response.paymentUrl);

      if (uri == null || response.paymentUrl.isEmpty) {
        _showError('VNPay integration is not available yet');
        return;
      }

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;

      if (!opened) {
        _showError('Could not open VNPay payment page');
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        '/payment-result',
        arguments: order.orderId,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    }
  }

  void _showError(String message) {
    final cleanMessage = message.replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(cleanMessage)));

    if (cleanMessage == 'Login required') {
      Navigator.pushNamed(context, '/login');
    }
  }

  Widget _buildPaymentMethod() {
    Widget paymentOption(String value, String label) {
      final selected = _paymentMethod == value;

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
        ),
        title: Text(label),
        onTap: _isSubmitting
            ? null
            : () {
                setState(() {
                  _paymentMethod = value;
                });
              },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        paymentOption('COD', 'COD'),
        paymentOption('VNPAY', 'VNPAY'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressIdController,
              keyboardType: TextInputType.number,
              enabled: !_isSubmitting,
              decoration: const InputDecoration(
                labelText: 'Address ID',
                helperText: 'Temporary field until address UI is available',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              enabled: !_isSubmitting,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _placeOrder,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
