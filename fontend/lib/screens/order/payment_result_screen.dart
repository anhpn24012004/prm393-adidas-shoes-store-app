import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class PaymentResultScreen extends StatefulWidget {
  final int orderId;

  const PaymentResultScreen({super.key, required this.orderId});

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  final OrderService _orderService = OrderService();

  PaymentStatus? _paymentStatus;
  bool _isLoading = false;
  String? _error;

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  Future<void> _refreshPaymentStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await _orderService.getPaymentStatus(widget.orderId);

      if (!mounted) return;

      setState(() {
        _paymentStatus = status;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToOrderDetail() {
    Navigator.pushReplacementNamed(
      context,
      '/order-detail',
      arguments: widget.orderId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _paymentStatus;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'After payment, return to app and refresh payment status.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (status != null) ...[
              Card(
                child: ListTile(
                  title: Text(status.orderCode),
                  subtitle: Text(
                    'Order: ${status.orderStatus}\n'
                    'Payment: ${status.paymentStatus}\n'
                    'Amount: ${formatPrice(status.amount)}',
                  ),
                  isThreeLine: true,
                ),
              ),
              if (status.paymentStatus == 'Success')
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Payment completed successfully.',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _refreshPaymentStatus,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Refresh Payment Status'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _goToOrderDetail,
                child: const Text('View Order Detail'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
