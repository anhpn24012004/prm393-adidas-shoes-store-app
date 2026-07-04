import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_config.dart';
import '../../models/address_model.dart';
import '../../models/ghn_model.dart';
import '../../models/order_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../services/ghn_service.dart';
import '../../services/order_service.dart';
import '../../utils/currency_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _discountAmount = 0;

  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final CartService _cartService = CartService();
  final GhnService _ghnService = GhnService();
  final TextEditingController _noteController = TextEditingController();

  late Future<List<UserAddress>> _addresses;
  late Future<List<GhnProvince>> _provincesFuture;
  int? _selectedAddressId;
  UserAddress? _selectedAddress;
  int? _buyNowVariantId;
  int? _buyNowQuantity;
  double? _buyNowUnitPrice;
  String? _buyNowProductName;
  String? _buyNowImageUrl;
  String? _buyNowSize;
  String? _buyNowColor;
  Future<_CheckoutSummary>? _summaryFuture;
  List<GhnDistrict> _districts = [];
  List<GhnWard> _wards = [];
  GhnProvince? _selectedProvince;
  GhnDistrict? _selectedDistrict;
  GhnWard? _selectedWard;
  double? _calculatedShippingFee;
  String? _ghnError;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;
  bool _isCalculatingShippingFee = false;
  String _paymentMethod = 'COD';
  bool _isSubmitting = false;
  bool _showPaymentStep = false;
  bool _routeArgumentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _addresses = _addressService.getAddresses();
    _provincesFuture = _ghnService.getProvinces();
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
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('selectShippingAddress'))),
      );
      return;
    }

    if (!_hasValidGhnShipping) {
      _showError(
        _ghnError ??
            'Vui lòng chọn đầy đủ tỉnh, quận/huyện và phường/xã để tính phí vận chuyển.',
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
        toDistrictId: _selectedDistrict!.districtId,
        toWardCode: _selectedWard!.wardCode,
        toProvinceName: _selectedProvince?.provinceName,
        toDistrictName: _selectedDistrict!.districtName,
        toWardName: _selectedWard!.wardName,
        shippingFee: _calculatedShippingFee!,
      );

      if (!mounted) return;

      if (_paymentMethod == 'VNPAY') {
        _showPaymentPendingMessage();
        await _handleVnPay(order);
        return;
      }

      if (_paymentMethod == 'PAYPAL') {
        _showPaymentPendingMessage();
        await _handlePayPal(order);
        return;
      }

      if (_paymentMethod == 'SEPAY') {
        _showPaymentPendingMessage();
        await _handleSePay(order);
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

    final selectedAddress = addresses.firstWhere(
      (address) => address.addressId == selectedAddressId,
    );
    await _applySavedAddress(selectedAddress);
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
        if (_selectedAddress?.addressId != selectedAddress.addressId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _applySavedAddress(selectedAddress);
          });
        }

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

  Future<_CheckoutSummary> _loadCheckoutSummary() async {
    if (_buyNowVariantId != null) {
      final quantity = _buyNowQuantity ?? 1;
      final subtotal = (_buyNowUnitPrice ?? 0) * quantity;

      return _CheckoutSummary(
        subtotal: subtotal,
        shippingFee: _calculatedShippingFee ?? 0,
        discountAmount: _discountAmount,
        finalAmount: subtotal + (_calculatedShippingFee ?? 0) - _discountAmount,
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
      shippingFee: _calculatedShippingFee ?? 0,
      discountAmount: _discountAmount,
      finalAmount:
          cart.totalAmount + (_calculatedShippingFee ?? 0) - _discountAmount,
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

    if (!_hasValidGhnShipping) {
      _showError(
        _ghnError ??
            'Vui lòng chọn đầy đủ tỉnh, quận/huyện và phường/xã để tính phí vận chuyển.',
      );
      return;
    }

    setState(() {
      _showPaymentStep = true;
    });
  }

  bool get _hasValidGhnShipping {
    return _selectedDistrict != null &&
        _selectedWard != null &&
        _calculatedShippingFee != null &&
        _calculatedShippingFee! > 0;
  }

  Future<void> _applySavedAddress(UserAddress address) async {
    final hasGhnCodes =
        address.provinceId != null &&
        address.provinceId! > 0 &&
        address.districtId != null &&
        address.districtId! > 0 &&
        address.wardCode?.trim().isNotEmpty == true;

    setState(() {
      _selectedAddressId = address.addressId;
      _selectedAddress = address;
      _selectedProvince = hasGhnCodes && address.provinceId != null
          ? GhnProvince(
              provinceId: address.provinceId!,
              provinceName: address.city ?? '',
            )
          : null;
      _selectedDistrict = hasGhnCodes
          ? GhnDistrict(
              districtId: address.districtId!,
              provinceId: address.provinceId ?? 0,
              districtName: address.district ?? '',
            )
          : null;
      _selectedWard = hasGhnCodes
          ? GhnWard(
              wardCode: address.wardCode!,
              districtId: address.districtId!,
              wardName: address.ward ?? '',
            )
          : null;
      _districts = [];
      _wards = [];
      _calculatedShippingFee = null;
      _ghnError = null;
      _summaryFuture = _loadCheckoutSummary();
    });

    if (hasGhnCodes) {
      await _calculateShippingFee(
        districtId: address.districtId!,
        wardCode: address.wardCode!,
      );
    }
  }

  Future<void> _loadDistricts(GhnProvince? province) async {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _selectedWard = null;
      _districts = [];
      _wards = [];
      _calculatedShippingFee = null;
      _ghnError = null;
      _isLoadingDistricts = province != null;
      _summaryFuture = _loadCheckoutSummary();
    });

    if (province == null) return;

    try {
      final districts = await _ghnService.getDistricts(province.provinceId);
      if (!mounted || _selectedProvince?.provinceId != province.provinceId) {
        return;
      }
      setState(() => _districts = districts);
    } catch (_) {
      if (mounted) setState(() => _ghnError = _ghnUnavailableMessage);
    } finally {
      if (mounted && _selectedProvince?.provinceId == province.provinceId) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  Future<void> _loadWards(GhnDistrict? district) async {
    setState(() {
      _selectedDistrict = district;
      _selectedWard = null;
      _wards = [];
      _calculatedShippingFee = null;
      _ghnError = null;
      _isLoadingWards = district != null;
      _summaryFuture = _loadCheckoutSummary();
    });

    if (district == null) return;

    try {
      final wards = await _ghnService.getWards(district.districtId);
      if (!mounted || _selectedDistrict?.districtId != district.districtId) {
        return;
      }
      setState(() => _wards = wards);
    } catch (_) {
      if (mounted) setState(() => _ghnError = _ghnUnavailableMessage);
    } finally {
      if (mounted && _selectedDistrict?.districtId == district.districtId) {
        setState(() => _isLoadingWards = false);
      }
    }
  }

  Future<void> _selectWard(GhnWard? ward) async {
    setState(() {
      _selectedWard = ward;
      _calculatedShippingFee = null;
      _ghnError = null;
      _summaryFuture = _loadCheckoutSummary();
    });

    if (ward == null || _selectedDistrict == null) return;

    await _calculateShippingFee(
      districtId: _selectedDistrict!.districtId,
      wardCode: ward.wardCode,
    );

    if (_calculatedShippingFee != null) {
      await _saveSelectedGhnLocation();
    }
  }

  Future<void> _saveSelectedGhnLocation() async {
    final address = _selectedAddress;
    final province = _selectedProvince;
    final district = _selectedDistrict;
    final ward = _selectedWard;
    if (address == null ||
        province == null ||
        district == null ||
        ward == null) {
      return;
    }

    try {
      final updated = await _addressService.updateAddress(
        address.addressId,
        SaveAddressRequest(
          receiverName: address.receiverName,
          phone: address.phone,
          addressLine: address.addressLine,
          city: province.provinceName,
          district: district.districtName,
          ward: ward.wardName,
          provinceId: province.provinceId,
          districtId: district.districtId,
          wardCode: ward.wardCode,
          isDefault: address.isDefault,
        ),
      );

      if (!mounted || _selectedAddressId != updated.addressId) return;
      setState(() {
        _selectedAddress = updated;
        _addresses = _addressService.getAddresses();
      });
    } catch (error) {
      if (mounted) {
        _showError(
          'Shipping fee was calculated, but the address could not be updated: $error',
        );
      }
    }
  }

  Future<void> _calculateShippingFee({
    required int districtId,
    required String wardCode,
  }) async {
    setState(() {
      _isCalculatingShippingFee = true;
      _ghnError = null;
    });

    try {
      final quantities = await _shippingQuantities();
      final fee = await _ghnService.calculateFee(
        toDistrictId: districtId,
        toWardCode: wardCode,
        quantities: quantities,
      );

      if (!mounted ||
          _selectedDistrict?.districtId != districtId ||
          _selectedWard?.wardCode != wardCode) {
        return;
      }

      setState(() {
        _calculatedShippingFee = fee.shippingFee;
        _summaryFuture = _loadCheckoutSummary();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _calculatedShippingFee = null;
        _ghnError = _ghnUnavailableMessage;
        _summaryFuture = _loadCheckoutSummary();
      });
    } finally {
      if (mounted) {
        setState(() => _isCalculatingShippingFee = false);
      }
    }
  }

  Future<List<int>> _shippingQuantities() async {
    if (_buyNowVariantId != null) {
      return [_buyNowQuantity ?? 1];
    }

    final cart = await _cartService.getCart(AppConfig.currentUserId);
    return cart.cartItems.map((item) => item.quantity).toList();
  }

  static const String _ghnUnavailableMessage =
      'Không thể tải dữ liệu GHN. Vui lòng kiểm tra cấu hình GHN.';

  Widget _buildGhnShippingSelector() {
    final address = _selectedAddress;
    final hasGhnCodes =
        address?.provinceId != null &&
        address!.provinceId! > 0 &&
        address.districtId != null &&
        address.districtId! > 0 &&
        address.wardCode?.trim().isNotEmpty == true;

    return FutureBuilder<List<GhnProvince>>(
      future: _provincesFuture,
      builder: (context, snapshot) {
        final provinces = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GHN delivery',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (address == null)
              const Text('Select a shipping address.')
            else if (!hasGhnCodes) ...[
              if (snapshot.hasError) ...[
                const Text(_ghnUnavailableMessage),
                TextButton(
                  onPressed: () => setState(
                    () => _provincesFuture = _ghnService.getProvinces(),
                  ),
                  child: const Text('Retry'),
                ),
              ] else ...[
                DropdownButtonFormField<GhnProvince>(
                  key: ValueKey(
                    'checkout-province-${_selectedProvince?.provinceId}',
                  ),
                  initialValue: _selectedProvince,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText:
                        snapshot.connectionState == ConnectionState.waiting
                        ? 'Loading provinces...'
                        : 'Province / City',
                    border: const OutlineInputBorder(),
                  ),
                  items: provinces
                      .map(
                        (province) => DropdownMenuItem(
                          value: province,
                          child: Text(
                            province.provinceName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      snapshot.connectionState == ConnectionState.waiting ||
                          _isSubmitting
                      ? null
                      : _loadDistricts,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GhnDistrict>(
                  key: ValueKey(
                    'checkout-district-${_selectedDistrict?.districtId}',
                  ),
                  initialValue: _selectedDistrict,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _isLoadingDistricts
                        ? 'Loading districts...'
                        : 'District',
                    border: const OutlineInputBorder(),
                  ),
                  items: _districts
                      .map(
                        (district) => DropdownMenuItem(
                          value: district,
                          child: Text(
                            district.districtName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      _selectedProvince == null ||
                          _isLoadingDistricts ||
                          _isSubmitting
                      ? null
                      : _loadWards,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<GhnWard>(
                  key: ValueKey('checkout-ward-${_selectedWard?.wardCode}'),
                  initialValue: _selectedWard,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _isLoadingWards ? 'Loading wards...' : 'Ward',
                    border: const OutlineInputBorder(),
                  ),
                  items: _wards
                      .map(
                        (ward) => DropdownMenuItem(
                          value: ward,
                          child: Text(
                            ward.wardName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged:
                      _selectedDistrict == null ||
                          _isLoadingWards ||
                          _isSubmitting
                      ? null
                      : _selectWard,
                ),
                const SizedBox(height: 8),
              ],
            ],
            if (_isCalculatingShippingFee)
              const LinearProgressIndicator()
            else if (_ghnError != null)
              Text(_ghnError!, style: const TextStyle(color: Colors.red))
            else if (_calculatedShippingFee != null)
              Text('Shipping fee: ${formatVnd(_calculatedShippingFee!)}')
            else if (hasGhnCodes)
              const Text('Calculating GHN shipping fee...'),
          ],
        );
      },
    );
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

  Future<void> _handleSePay(OrderDetail order) async {
    try {
      final payment = await _orderService.createSePayPayment(order.orderId);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/sepay-payment',
        arguments: payment,
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

  void _showPaymentPendingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Order created. Please complete your payment to confirm the order.',
        ),
      ),
    );
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
        paymentOption('SEPAY', 'SePay'),
      ],
    );
  }

  String get _paymentButtonLabel {
    return switch (_paymentMethod) {
      'VNPAY' => 'Pay with VNPAY',
      'PAYPAL' => 'Pay with PayPal',
      'SEPAY' => 'Pay with SePay',
      _ => 'Place order',
    };
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
                          : Text(_paymentButtonLabel),
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
                  _buildGhnShippingSelector(),
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
