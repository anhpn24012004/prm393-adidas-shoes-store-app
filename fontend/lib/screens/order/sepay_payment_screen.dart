import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class SePayPaymentScreen extends StatefulWidget {
  final SePayPaymentResponse payment;

  const SePayPaymentScreen({super.key, required this.payment});

  @override
  State<SePayPaymentScreen> createState() => _SePayPaymentScreenState();
}

class _SePayPaymentScreenState extends State<SePayPaymentScreen> {
  static const _pollInterval = Duration(seconds: 5);

  final OrderService _orderService = OrderService();
  Timer? _pollTimer;
  Timer? _countdownTimer;
  bool _checking = false;
  bool _navigating = false;
  String? _networkMessage;
  Duration _remaining = Duration.zero;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    _expiresAt = widget.payment.expiresAt?.toLocal();
    _updateRemaining();
    _startTimers();
    _checkStatus(silent: true);
  }

  void _startTimers() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();

    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus(silent: true));
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining();
      if (_remaining <= Duration.zero && !_checking && !_navigating) {
        _checkStatus(silent: true);
      }
    });
  }

  void _updateRemaining() {
    final expiresAt = _expiresAt;
    if (expiresAt == null) {
      if (_remaining != Duration.zero) {
        setState(() => _remaining = Duration.zero);
      }
      return;
    }

    final next = expiresAt.difference(DateTime.now());
    final clamped = next.isNegative ? Duration.zero : next;
    if (clamped != _remaining) {
      setState(() => _remaining = clamped);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_checking || _navigating) return;

    if (!silent && mounted) {
      setState(() {
        _checking = true;
        _networkMessage = null;
      });
    } else {
      _checking = true;
    }

    try {
      final status = await _orderService.getPaymentStatus(
        widget.payment.orderId,
      );
      if (!mounted) return;

      if (status.expiresAt != null) {
        _expiresAt = status.expiresAt!.toLocal();
        _updateRemaining();
      }

      if (status.isSuccess) {
        await _navigateToResult('success');
        return;
      }

      if (status.isFailed) {
        final resultStatus = status.paymentStatus == 'Expired' ||
                status.message?.toLowerCase().contains('expired') == true
            ? 'expired'
            : 'failed';
        await _navigateToResult(resultStatus);
        return;
      }
    } catch (error, stackTrace) {
      debugPrint('SePay status poll failed: $error\n$stackTrace');
      if (!mounted) return;
      if (!silent) {
        setState(
          () => _networkMessage =
              'Could not check payment status. Will retry automatically.',
        );
      }
    } finally {
      _checking = false;
      if (mounted && !silent) {
        setState(() {});
      }
    }
  }

  Future<void> _navigateToResult(String status) async {
    if (_navigating || !mounted) return;
    _navigating = true;
    _pollTimer?.cancel();
    _countdownTimer?.cancel();

    if (status == 'success') {
      setState(() {});
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/payment-result',
      arguments: {
        'orderId': widget.payment.orderId,
        'status': status,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;
    final hasExpiry = _expiresAt != null;

    return Scaffold(
      appBar: AppBar(title: const Text('SePay Payment')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (payment.qrCodeUrl.isNotEmpty)
                Center(
                  child: Image.network(
                    payment.qrCodeUrl,
                    width: 260,
                    height: 260,
                    errorBuilder: (_, _, _) =>
                        const Text('Could not load payment QR code.'),
                  ),
                ),
              const SizedBox(height: 20),
              _info('Total amount', formatVnd(payment.amount)),
              _info('Bank code', payment.bankCode),
              _info('Account number', payment.bankAccountNumber),
              _info('Account name', payment.accountName),
              _info('Transfer content', payment.transferContent),
              const SizedBox(height: 16),
              const Text(
                'Please transfer the exact amount with the correct content. '
                'Your order will be confirmed automatically after payment is received.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_checking)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_checking) const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Waiting for payment confirmation...',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasExpiry) ...[
                const SizedBox(height: 8),
                Text(
                  _remaining > Duration.zero
                      ? 'Payment expires in ${_formatCountdown(_remaining)}'
                      : 'Payment window has ended. Checking status...',
                  style: TextStyle(
                    color: _remaining > Duration.zero
                        ? Colors.orange.shade800
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (_networkMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _networkMessage!,
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checking || _navigating
                    ? null
                    : () => _checkStatus(silent: false),
                child: const Text('Check payment status'),
              ),
            ],
          ),
          if (_navigating)
            Container(
              color: Colors.black26,
              alignment: Alignment.center,
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Payment confirmed. Redirecting...'),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
