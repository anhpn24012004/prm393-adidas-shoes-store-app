import 'package:flutter/material.dart';

import '../../models/address_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../theme/app_theme.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _service = AddressService();

  UserAddress? _address;
  bool _initialized = false;
  bool _isDefault = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is UserAddress) {
      _address = argument;
      _nameController.text = argument.receiverName;
      _phoneController.text = argument.phone;
      _addressController.text = argument.addressLine;
      _wardController.text = argument.ward ?? '';
      _districtController.text = argument.district ?? '';
      _cityController.text = argument.city ?? '';
      _isDefault = argument.isDefault;
    }
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final request = SaveAddressRequest(
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressController.text.trim(),
      ward: _nullable(_wardController.text),
      district: _nullable(_districtController.text),
      city: _nullable(_cityController.text),
      isDefault: _isDefault,
    );

    try {
      if (_address == null) {
        await _service.createAddress(request);
      } else {
        await _service.updateAddress(_address!.addressId, request);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty
        ? context.tr('requiredField')
        : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (_address == null
                  ? context.tr('addAddress')
                  : context.tr('editAddress'))
              .toUpperCase(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              (_address == null
                      ? context.tr('newDeliveryAddress')
                      : context.tr('updateAddress'))
                  .toUpperCase(),
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _nameController,
              validator: _required,
              decoration: InputDecoration(
                labelText: context.tr('receiverName'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneController,
              validator: (value) {
                final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                return digits.length < 8 ? context.tr('invalidPhone') : null;
              },
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.tr('phoneNumber'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _addressController,
              validator: _required,
              decoration: InputDecoration(
                labelText: context.tr('streetAddress'),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _wardController,
              decoration: InputDecoration(labelText: context.tr('ward')),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _districtController,
              decoration: InputDecoration(labelText: context.tr('district')),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: context.tr('cityProvince'),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                context.tr('setDefaultAddress'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                context.tr('setDefaultAddressSubtitle'),
                style: const TextStyle(color: AppColors.muted),
              ),
              value: _isDefault,
              onChanged: _address?.isDefault == true
                  ? null
                  : (value) => setState(() => _isDefault = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(
                (_saving ? context.tr('saving') : context.tr('saveAddress'))
                    .toUpperCase(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
