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
  int? _buyNowVariantId;
  int? _buyNowQuantity;
  String _paymentMethod = 'COD';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addresses = _addressService.getAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      _buyNowVariantId = arguments['variantId'] as int?;
      _buyNowQuantity = arguments['quantity'] as int?;
    }
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
        buyNowVariantId: _buyNowVariantId,
        buyNowQuantity: _buyNowQuantity,
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

  Future<void> _openAddressPicker(List<UserAddress> addresses) async {
    final selectedAddressId = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  context.tr('selectAddress').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final selected = address.addressId == _selectedAddressId;

                    return ListTile(
                      leading: Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.receiverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
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
                      subtitle: Text(
                        '${address.phone}\n${address.formattedAddress}',
                      ),
                      isThreeLine: true,
                      onTap: () => Navigator.pop(context, address.addressId),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.pushNamed(context, '/address-form');
                      if (mounted) {
                        setState(() {
                          _addresses = _addressService.getAddresses();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text(context.tr('addShippingAddress').toUpperCase()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedAddressId == null || !mounted) return;

    setState(() {
      _selectedAddressId = selectedAddressId;
    });
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

        final selectedAddress = addresses.firstWhere(
          (address) => address.addressId == _selectedAddressId,
          orElse: () => addresses.first,
        );

        return InkWell(
          onTap: _isSubmitting ? null : () => _openAddressPicker(addresses),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.location_on_outlined),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedAddress.receiverName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (selectedAddress.isDefault)
                            Text(
                              context.tr('defaultLabel').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(selectedAddress.phone),
                      Text(
                        selectedAddress.formattedAddress,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.keyboard_arrow_down),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('changeAddress').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
