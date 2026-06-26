import 'package:flutter/material.dart';

import '../../models/address_model.dart';
import '../../models/ghn_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../services/ghn_service.dart';
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
  final _service = AddressService();
  final _ghnService = GhnService();

  UserAddress? _address;
  List<GhnProvince> _provinces = [];
  List<GhnDistrict> _districts = [];
  List<GhnWard> _wards = [];
  GhnProvince? _selectedProvince;
  GhnDistrict? _selectedDistrict;
  GhnWard? _selectedWard;
  bool _initialized = false;
  bool _isDefault = false;
  bool _saving = false;
  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;
  bool _isLoadingWards = false;

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
      _isDefault = argument.isDefault;
    }
    _initialized = true;
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);

    try {
      final provinces = await _ghnService.getProvinces();
      if (!mounted) return;

      setState(() {
        _provinces = provinces;
        _selectedProvince = _findProvince(provinces, _address?.provinceId);
      });

      if (_selectedProvince != null) {
        await _loadDistricts(_selectedProvince, restoreSavedValue: true);
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _isLoadingProvinces = false);
    }
  }

  GhnProvince? _findProvince(List<GhnProvince> items, int? id) {
    for (final item in items) {
      if (item.provinceId == id) return item;
    }
    return null;
  }

  GhnDistrict? _findDistrict(List<GhnDistrict> items, int? id) {
    for (final item in items) {
      if (item.districtId == id) return item;
    }
    return null;
  }

  GhnWard? _findWard(List<GhnWard> items, String? code) {
    for (final item in items) {
      if (item.wardCode == code) return item;
    }
    return null;
  }

  Future<void> _loadDistricts(
    GhnProvince? province, {
    bool restoreSavedValue = false,
  }) async {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;
      _selectedWard = null;
      _districts = [];
      _wards = [];
      _isLoadingDistricts = province != null;
    });

    if (province == null) return;

    try {
      final districts = await _ghnService.getDistricts(province.provinceId);
      if (!mounted || _selectedProvince?.provinceId != province.provinceId) {
        return;
      }

      final savedDistrict = restoreSavedValue
          ? _findDistrict(districts, _address?.districtId)
          : null;
      setState(() {
        _districts = districts;
        _selectedDistrict = savedDistrict;
      });

      if (savedDistrict != null) {
        await _loadWards(savedDistrict, restoreSavedValue: true);
      }
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted && _selectedProvince?.provinceId == province.provinceId) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  Future<void> _loadWards(
    GhnDistrict? district, {
    bool restoreSavedValue = false,
  }) async {
    setState(() {
      _selectedDistrict = district;
      _selectedWard = null;
      _wards = [];
      _isLoadingWards = district != null;
    });

    if (district == null) return;

    try {
      final wards = await _ghnService.getWards(district.districtId);
      if (!mounted || _selectedDistrict?.districtId != district.districtId) {
        return;
      }

      setState(() {
        _wards = wards;
        _selectedWard = restoreSavedValue
            ? _findWard(wards, _address?.wardCode)
            : null;
      });
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted && _selectedDistrict?.districtId == district.districtId) {
        setState(() => _isLoadingWards = false);
      }
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final request = SaveAddressRequest(
      receiverName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      addressLine: _addressController.text.trim(),
      ward: _selectedWard!.wardName,
      district: _selectedDistrict!.districtName,
      city: _selectedProvince!.provinceName,
      provinceId: _selectedProvince!.provinceId,
      districtId: _selectedDistrict!.districtId,
      wardCode: _selectedWard!.wardCode,
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
              decoration: InputDecoration(labelText: context.tr('phoneNumber')),
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
            DropdownButtonFormField<GhnProvince>(
              key: ValueKey('province-${_selectedProvince?.provinceId}'),
              initialValue: _selectedProvince,
              isExpanded: true,
              validator: (value) =>
                  value == null ? context.tr('requiredField') : null,
              decoration: InputDecoration(
                labelText: _isLoadingProvinces
                    ? 'Loading provinces...'
                    : context.tr('cityProvince'),
              ),
              items: _provinces
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
              onChanged: _isLoadingProvinces || _saving
                  ? null
                  : (province) => _loadDistricts(province),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<GhnDistrict>(
              key: ValueKey('district-${_selectedDistrict?.districtId}'),
              initialValue: _selectedDistrict,
              isExpanded: true,
              validator: (value) =>
                  value == null ? context.tr('requiredField') : null,
              decoration: InputDecoration(
                labelText: _isLoadingDistricts
                    ? 'Loading districts...'
                    : context.tr('district'),
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
                  _selectedProvince == null || _isLoadingDistricts || _saving
                  ? null
                  : (district) => _loadWards(district),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<GhnWard>(
              key: ValueKey('ward-${_selectedWard?.wardCode}'),
              initialValue: _selectedWard,
              isExpanded: true,
              validator: (value) =>
                  value == null ? context.tr('requiredField') : null,
              decoration: InputDecoration(
                labelText: _isLoadingWards
                    ? 'Loading wards...'
                    : context.tr('ward'),
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
              onChanged: _selectedDistrict == null || _isLoadingWards || _saving
                  ? null
                  : (ward) => setState(() => _selectedWard = ward),
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
