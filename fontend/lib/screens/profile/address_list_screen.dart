import 'package:flutter/material.dart';

import '../../models/address_model.dart';
import '../../localization/app_localization.dart';
import '../../services/address_service.dart';
import '../../theme/app_theme.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _service = AddressService();
  late Future<List<UserAddress>> _addresses;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _addresses = _service.getAddresses();
  }

  Future<void> _openForm([UserAddress? address]) async {
    final changed = await Navigator.pushNamed(
      context,
      '/address-form',
      arguments: address,
    );
    if (changed == true && mounted) {
      setState(_reload);
    }
  }

  Future<void> _setDefault(UserAddress address) async {
    try {
      await _service.setDefault(address.addressId);
      if (mounted) setState(_reload);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _delete(UserAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('deleteAddressQuestion')),
        content: Text(address.formattedAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel').toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.tr('delete').toUpperCase()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _service.deleteAddress(address.addressId);
      if (mounted) setState(_reload);
    } catch (error) {
      _showError(error);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('Exception: ', '')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('myAddresses').toUpperCase())),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(context.tr('addAddress').toUpperCase()),
      ),
      body: FutureBuilder<List<UserAddress>>(
        future: _addresses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error
                  .toString()
                  .replaceFirst('Exception: ', ''),
              onRetry: () => setState(_reload),
            );
          }

          final addresses = snapshot.data ?? [];
          if (addresses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off_outlined, size: 54),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('noAddresses').toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('noAddressesSubtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _openForm,
                      child: Text(
                        context.tr('addFirstAddress').toUpperCase(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
            itemCount: addresses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final address = addresses[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.receiverName.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (address.isDefault)
                            Chip(
                              label: Text(
                                context.tr('defaultLabel').toUpperCase(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(address.phone),
                      const SizedBox(height: 4),
                      Text(address.formattedAddress),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => _openForm(address),
                            child: Text(context.tr('edit').toUpperCase()),
                          ),
                          if (!address.isDefault)
                            TextButton(
                              onPressed: () => _setDefault(address),
                              child: Text(
                                context.tr('setDefault').toUpperCase(),
                              ),
                            ),
                          TextButton(
                            onPressed: () => _delete(address),
                            child: Text(context.tr('delete').toUpperCase()),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.tr('retry').toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}
