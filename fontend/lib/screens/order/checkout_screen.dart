import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final TextEditingController _noteController = TextEditingController();

  late Future<List<UserAddress>> _addresses;
  int? _selectedAddressId;
  String _paymentMethod = 'COD';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addresses = _addressService.getAddresses();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectShippingAddress'))),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final order = await _orderService.createOrder(
        addressId: _selectedAddressId!,
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
        SnackBar(content: Text(context.tr('orderCreated'))),
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

  Widget _buildAddressSelector() {
    return FutureBuilder<List<UserAddress>>(
      future: _addresses,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.error.toString().replaceFirst('Exception: ', ''),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _addresses = _addressService.getAddresses();
                }),
                child: Text(context.tr('retry').toUpperCase()),
              ),
            ],
          );
        }

        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return OutlinedButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, '/address-form');
              if (mounted) {
                setState(() {
                  _addresses = _addressService.getAddresses();
                });
              }
            },
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(context.tr('addShippingAddress').toUpperCase()),
          );
        }

        _selectedAddressId ??= addresses
            .where((address) => address.isDefault)
            .map((address) => address.addressId)
            .firstOrNull;
        _selectedAddressId ??= addresses.first.addressId;

        return Column(
          children: addresses.map((address) {
            return RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              value: address.addressId,
              groupValue: _selectedAddressId,
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedAddressId = value),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      address.receiverName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (address.isDefault)
                    Text(
                      context.tr('defaultLabel').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
              subtitle: Text('${address.phone}\n${address.formattedAddress}'),
              isThreeLine: true,
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _handleVnPay(OrderDetail order) async {
    try {
      final response = await _orderService.createVnPayPayment(order.orderId);
      final uri = Uri.tryParse(response.paymentUrl);

      if (uri == null || response.paymentUrl.isEmpty) {
        _showError(context.tr('vnpayUnavailable'));
        return;
      }

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;

      if (!opened) {
        _showError(context.tr('cannotOpenVnpay'));
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
        Text(
          context.tr('paymentMethod'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        paymentOption('COD', 'COD'),
        paymentOption('VNPAY', 'VNPAY'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('checkout'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('shippingAddress'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildAddressSelector(),
            const SizedBox(height: 20),
            _buildPaymentMethod(),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              enabled: !_isSubmitting,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: context.tr('note'),
                border: const OutlineInputBorder(),
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
                    : Text(context.tr('placeOrder')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
