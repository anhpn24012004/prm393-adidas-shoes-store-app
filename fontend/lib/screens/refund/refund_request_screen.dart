import 'package:flutter/material.dart';

import '../../config/app_config.dart';
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
  final _reasonController = TextEditingController();
  OrderDetail? _order;
  final Map<int, int> _quantities = {};
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

  Future<void> _load(int orderId) async {
    try {
      final order = await _orderService.getOrderDetail(orderId);
      if (mounted) setState(() => _order = order);
    } catch (error) {
      if (mounted) _show(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final selected = _quantities.entries.where((entry) => entry.value > 0);
    if (_order == null ||
        _reasonController.text.trim().isEmpty ||
        selected.isEmpty) {
      _show('Select at least one item and enter a return reason.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await _returnService.createReturn(
        orderId: _order!.orderId,
        userId: AppConfig.currentUserId,
        reason: _reasonController.text.trim(),
        items: selected
            .map(
              (entry) => {
                'orderItemId': entry.key,
                'quantity': entry.value,
                'reason': _reasonController.text.trim(),
              },
            )
            .toList(),
      );
      if (!mounted) return;
      _show('Return request submitted.');
      Navigator.pushReplacementNamed(context, '/refund-status');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REQUEST A RETURN')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? const Center(child: Text('Open this screen from an order detail.'))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'RETURN ITEMS',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_order!.orderCode}  •  ${_order!.status}',
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 22),
                ..._order!.items.map((item) {
                  final quantity = _quantities[item.orderItemId] ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text('${item.size} / ${item.color}'),
                                Text('Purchased: ${item.quantity}'),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: quantity > 0
                                ? () => setState(
                                    () => _quantities[item.orderItemId] =
                                        quantity - 1,
                                  )
                                : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          IconButton(
                            onPressed: quantity < item.quantity
                                ? () => setState(
                                    () => _quantities[item.orderItemId] =
                                        quantity + 1,
                                  )
                                : null,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason for return',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: Text(
                    _submitting ? 'SUBMITTING...' : 'SUBMIT RETURN REQUEST',
                  ),
                ),
              ],
            ),
    );
  }
}
