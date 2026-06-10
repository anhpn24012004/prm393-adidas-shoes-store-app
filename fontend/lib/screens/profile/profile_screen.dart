import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<bool>(
        future: AuthStorage().isAdmin(),
        builder: (context, snapshot) {
          final isAdmin = snapshot.data ?? false;

          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('My Orders'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/orders'),
              ),
              if (isAdmin)
                ListTile(
                  leading: const Icon(Icons.local_shipping),
                  title: const Text('Shipment Management'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/admin/shipments'),
                ),
            ],
          );
        },
      ),
    );
  }
}
