import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class PaymentResultScreen extends StatefulWidget {
  final int orderId;
  final String? statusHint;

  const PaymentResultScreen({
    super.key,
    required this.orderId,
    this.statusHint,
  });

  @override
  State<PaymentResultScreen> createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen>
    with WidgetsBindingObserver {
  final OrderService _orderService = OrderService();

  PaymentStatus? _paymentStatus;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPaymentStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPaymentStatus();
    }
  }

  String formatPrice(double price) {
    return formatVnd(price);
  }

  Future<void> _refreshPaymentStatus() async {
    if (widget.orderId <= 0 || _isLoading) return;

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

  String? _resultMessage(PaymentStatus status) {
    if (status.message != null && status.message!.isNotEmpty) {
      return status.message;
    }

    if (status.isSuccess) {
      return context.tr('paymentCompleted');
    }

    if (status.paymentStatus == 'Expired') {
      return 'Payment expired.';
    }

    if (status.isFailed) {
      return 'Payment failed or expired.';
    }

    return null;
  }

  Color? _resultColor(PaymentStatus status) {
    if (status.isSuccess) return Colors.green;
    if (status.isFailed || status.paymentStatus == 'Expired') {
      return Colors.red;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final status = _paymentStatus;
    final resultMessage = status != null ? _resultMessage(status) : null;
    final resultColor = status != null ? _resultColor(status) : null;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('paymentStatus'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('paymentResultHint'),
              style: const TextStyle(fontSize: 16),
            ),
            if (widget.statusHint != null && status == null && _isLoading) ...[
              const SizedBox(height: 8),
              Text(
                'Loading latest payment status...',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (status != null) ...[
              Card(
                child: ListTile(
                  title: Text(status.orderCode),
                  subtitle: Text(
                    '${context.tr('order')}: ${status.orderStatus}\n'
                    '${context.tr('payment')}: ${status.paymentStatus}\n'
                    '${context.tr('amount')}: ${formatPrice(status.amount)}',
                  ),
                  isThreeLine: true,
                ),
              ),
              if (resultMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    resultMessage,
                    style: TextStyle(
                      color: resultColor,
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
                label: Text(context.tr('refreshPaymentStatus')),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _goToOrderDetail,
                child: Text(context.tr('viewOrderDetail')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
