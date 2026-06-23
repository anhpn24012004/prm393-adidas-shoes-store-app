import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../models/address_model.dart';
import '../../models/order_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _shippingFee = 30000;
  static const double _discountAmount = 0;

  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final CartService _cartService = CartService();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _visaCardNumberController =
      TextEditingController();
  final TextEditingController _visaCardHolderController =
      TextEditingController();
  final TextEditingController _visaExpiryController = TextEditingController();
  final TextEditingController _visaCvvController = TextEditingController();

  late Future<List<UserAddress>> _addresses;
  int? _selectedAddressId;
  int? _buyNowVariantId;
  int? _buyNowQuantity;
  double? _buyNowUnitPrice;
  String? _buyNowProductName;
  String? _buyNowImageUrl;
  String? _buyNowSize;
  String? _buyNowColor;
  Future<_CheckoutSummary>? _summaryFuture;
  String _paymentMethod = 'COD';
  bool _isSubmitting = false;
  bool _showPaymentStep = false;
  bool _routeArgumentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _addresses = _addressService.getAddresses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_routeArgumentsLoaded) return;
    _routeArgumentsLoaded = true;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      _buyNowVariantId = arguments['variantId'] as int?;
      _buyNowQuantity = arguments['quantity'] as int?;
      _buyNowUnitPrice = (arguments['unitPrice'] as num?)?.toDouble();
      _buyNowProductName = arguments['productName']?.toString();
      _buyNowImageUrl = arguments['imageUrl']?.toString();
      _buyNowSize = arguments['size']?.toString();
      _buyNowColor = arguments['color']?.toString();
    }

    _summaryFuture = _loadCheckoutSummary();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _visaCardNumberController.dispose();
    _visaCardHolderController.dispose();
    _visaExpiryController.dispose();
    _visaCvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectShippingAddress'))),
      );
      return;
    }

    VisaPaymentRequest? visaPayment;

    if (_paymentMethod == 'VISA') {
      visaPayment = await _collectVisaPayment();

      if (visaPayment == null) {
        return;
      }
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

      if (_paymentMethod == 'PAYPAL') {
        await _handlePayPal(order);
        return;
      }

      if (_paymentMethod == 'QR') {
        await _handleQrPayment(order);
        return;
      }

      if (_paymentMethod == 'VISA') {
        await _handleVisa(order, visaPayment!);
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('orderCreated'))));

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

  Future<VisaPaymentRequest?> _collectVisaPayment() async {
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Visa'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _visaCardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.tr('visaCardNumber'),
                      prefixIcon: const Icon(Icons.credit_card),
                    ),
                    validator: _validateVisaCardNumber,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _visaCardHolderController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: context.tr('visaCardHolder'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return context.tr('requiredField');
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _visaExpiryController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: context.tr('visaExpiry'),
                            hintText: 'MM/YY',
                          ),
                          validator: _validateVisaExpiry,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _visaCvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: context.tr('visaCvv'),
                          ),
                          validator: _validateVisaCvv,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.tr('cancel').toUpperCase()),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(context.tr('confirm').toUpperCase()),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return null;
    }

    final expiryParts = _visaExpiryController.text.trim().split('/');

    return VisaPaymentRequest(
      orderId: 0,
      cardNumber: _visaCardNumberController.text.trim(),
      cardHolderName: _visaCardHolderController.text.trim(),
      expiryMonth: expiryParts[0].trim(),
      expiryYear: expiryParts[1].trim(),
      cvv: _visaCvvController.text.trim(),
    );
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
              Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
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
    final unavailableMessage = context.tr('vnpayUnavailable');
    final cannotOpenMessage = context.tr('cannotOpenVnpay');

    try {
      final response = await _orderService.createVnPayPayment(order.orderId);
      final uri = Uri.tryParse(response.paymentUrl);

      if (uri == null || response.paymentUrl.isEmpty) {
        _showError(unavailableMessage);
        return;
      }

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;

      if (!opened) {
        _showError(cannotOpenMessage);
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

  Future<void> _handleVisa(
    OrderDetail order,
    VisaPaymentRequest payment,
  ) async {
    try {
      await _orderService.payWithVisa(
        VisaPaymentRequest(
          orderId: order.orderId,
          cardNumber: payment.cardNumber,
          cardHolderName: payment.cardHolderName,
          expiryMonth: payment.expiryMonth,
          expiryYear: payment.expiryYear,
          cvv: payment.cvv,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('paymentCompleted'))));

      Navigator.pushReplacementNamed(
        context,
        '/order-detail',
        arguments: order.orderId,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    }
  }

  Future<_CheckoutSummary> _loadCheckoutSummary() async {
    if (_buyNowVariantId != null) {
      final quantity = _buyNowQuantity ?? 1;
      final subtotal = (_buyNowUnitPrice ?? 0) * quantity;

      return _CheckoutSummary(
        subtotal: subtotal,
        shippingFee: _shippingFee,
        discountAmount: _discountAmount,
        finalAmount: subtotal + _shippingFee - _discountAmount,
        totalItems: quantity,
        title: _buyNowProductName ?? 'Buy now item',
        imageUrl: _buyNowImageUrl,
        variantLabel: [
          if (_buyNowSize?.isNotEmpty == true) 'Size $_buyNowSize',
          if (_buyNowColor?.isNotEmpty == true) _buyNowColor!,
        ].join(' / '),
      );
    }

    final cart = await _cartService.getCart(AppConfig.currentUserId);

    return _CheckoutSummary(
      subtotal: cart.totalAmount,
      shippingFee: _shippingFee,
      discountAmount: _discountAmount,
      finalAmount: cart.totalAmount + _shippingFee - _discountAmount,
      totalItems: cart.totalItems,
      title: 'Cart items',
    );
  }

  Widget _buildOrderSummary({bool compact = false}) {
    final summaryFuture = _summaryFuture;

    if (summaryFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<_CheckoutSummary>(
      future: summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(snapshot.error.toString().replaceFirst('Exception: ', '')),
              TextButton(
                onPressed: () {
                  setState(() {
                    _summaryFuture = _loadCheckoutSummary();
                  });
                },
                child: Text(context.tr('retry').toUpperCase()),
              ),
            ],
          );
        }

        final summary = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              compact ? 'Order total' : 'Order summary',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (!compact) ...[
              if (summary.imageUrl?.isNotEmpty == true) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        AppConfig.resolveImageUrl(summary.imageUrl!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(summary.title),
                          if (summary.variantLabel?.isNotEmpty == true)
                            Text(
                              summary.variantLabel!,
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              _summaryRow('Items', '${summary.totalItems}'),
              _summaryRow('Product', summary.title),
            ],
            _summaryRow('Subtotal', formatVnd(summary.subtotal)),
            _summaryRow('Shipping', formatVnd(summary.shippingFee)),
            if (summary.discountAmount > 0)
              _summaryRow('Discount', '-${formatVnd(summary.discountAmount)}'),
            const Divider(height: 22),
            _summaryRow(
              'Total',
              formatVnd(summary.finalAmount),
              emphasized: true,
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) {
    final style = TextStyle(
      fontSize: emphasized ? 17 : 14,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }

  void _continueToPayment() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectShippingAddress'))),
      );
      return;
    }

    setState(() {
      _showPaymentStep = true;
    });
  }

  void _backToReview() {
    setState(() {
      _showPaymentStep = false;
    });
  }

  Future<void> _handlePayPal(OrderDetail order) async {
    try {
      final response = await _orderService.createPayPalPayment(order.orderId);
      final uri = Uri.tryParse(response.approvalUrl);

      if (uri == null || response.approvalUrl.isEmpty) {
        _showError('PayPal integration is not available yet');
        return;
      }

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!mounted) return;

      if (!opened) {
        _showError('Could not open PayPal payment page');
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

  Future<void> _handleQrPayment(OrderDetail order) async {
    try {
      final payment = await _orderService.createQrPayment(order.orderId);

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('QR Payment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.network(
                      payment.qrImageUrl,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) {
                        return const SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(child: Text('Could not load QR image')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _qrInfoRow('Amount', formatVnd(payment.amount)),
                  _qrInfoRow('Account', payment.accountNo),
                  _qrInfoRow('Name', payment.accountName),
                  _qrInfoRow('Content', payment.transferContent),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan this QR with your banking app. Your order will stay pending until the transfer is confirmed.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _orderService.confirmQrPayment(order.orderId);

                    if (!context.mounted) return;

                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          e.toString().replaceFirst('Exception: ', ''),
                        ),
                      ),
                    );
                  }
                },
                child: const Text('I have transferred'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (confirmed != true) {
        Navigator.pushReplacementNamed(
          context,
          '/order-detail',
          arguments: order.orderId,
        );
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Payment successful'),
            content: const Text('Your QR payment has been confirmed.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View order'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/order-detail',
        arguments: order.orderId,
      );
    } catch (e) {
      if (!mounted) return;

      _showError(e.toString());
    }
  }

  Widget _qrInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }

  String? _validateVisaCardNumber(String? value) {
    final digits = _digitsOnly(value);

    if (digits.length < 13 ||
        digits.length > 19 ||
        !digits.startsWith('4') ||
        !_passesLuhn(digits)) {
      return context.tr('invalidVisaCard');
    }

    return null;
  }

  String? _validateVisaExpiry(String? value) {
    final match = RegExp(
      r'^(\d{1,2})/(\d{2}|\d{4})$',
    ).firstMatch((value ?? '').trim());

    if (match == null) {
      return context.tr('invalidVisaExpiry');
    }

    final month = int.tryParse(match.group(1)!);
    var year = int.tryParse(match.group(2)!);

    if (month == null || month < 1 || month > 12 || year == null) {
      return context.tr('invalidVisaExpiry');
    }

    if (year < 100) {
      year += 2000;
    }

    final lastValidDate = DateTime(year, month + 1, 0);
    final today = DateTime.now();

    if (lastValidDate.isBefore(DateTime(today.year, today.month, today.day))) {
      return context.tr('invalidVisaExpiry');
    }

    return null;
  }

  String? _validateVisaCvv(String? value) {
    final digits = _digitsOnly(value);

    if (digits.length < 3 || digits.length > 4) {
      return context.tr('invalidVisaCvv');
    }

    return null;
  }

  String _digitsOnly(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\D'), '');
  }

  bool _passesLuhn(String value) {
    var sum = 0;
    var doubleDigit = false;

    for (var index = value.length - 1; index >= 0; index--) {
      var digit = int.parse(value[index]);

      if (doubleDigit) {
        digit *= 2;

        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      doubleDigit = !doubleDigit;
    }

    return sum % 10 == 0;
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
        paymentOption('PAYPAL', 'PayPal'),
        paymentOption('QR', 'QR'),
        paymentOption('VISA', 'Visa'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showPaymentStep
              ? context.tr('paymentMethod')
              : context.tr('checkout'),
        ),
        leading: _showPaymentStep
            ? IconButton(
                onPressed: _isSubmitting ? null : _backToReview,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _showPaymentStep
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderSummary(compact: true),
                  const SizedBox(height: 20),
                  _buildPaymentMethod(),
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isSubmitting ? null : _backToReview,
                      child: const Text('Back to review'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('shippingAddress'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAddressSelector(),
                  const SizedBox(height: 20),
                  _buildOrderSummary(),
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
                      onPressed: _isSubmitting ? null : _continueToPayment,
                      child: const Text('Continue to payment'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CheckoutSummary {
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final int totalItems;
  final String title;
  final String? imageUrl;
  final String? variantLabel;

  const _CheckoutSummary({
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.totalItems,
    required this.title,
    this.imageUrl,
    this.variantLabel,
  });
}
