import 'package:flutter/material.dart';

import '../../services/auth_storage.dart';
import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';
import '../../widgets/store_brand.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _editProfile() async {
    final updated = await Navigator.pushNamed(context, '/edit-profile');

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const StoreBrand(size: 27)),
      body: FutureBuilder<List<Object?>>(
        future: Future.wait<Object?>([
          AuthStorage().getToken(),
          AuthStorage().isAdmin(),
        ]),
        builder: (context, snapshot) {
          final values = snapshot.data;
          final signedIn =
              values != null &&
              values.isNotEmpty &&
              values[0]?.toString().isNotEmpty == true;
          final isAdmin =
              snapshot.data != null &&
              snapshot.data!.length > 1 &&
              snapshot.data![1] == true;
          final storage = AuthStorage();
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Text(
                context.tr('myAccount').toUpperCase(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 22),
              FutureBuilder<List<String?>>(
                future: Future.wait([
                  storage.getFullName(),
                  storage.getEmail(),
                ]),
                builder: (context, userSnapshot) {
                  final values = userSnapshot.data ?? [];
                  final name = values.isNotEmpty ? values[0] : null;
                  final email = values.length > 1 ? values[1] : null;
                  return InkWell(
                    onTap: signedIn ? _editProfile : null,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      color: AppColors.black,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: AppColors.black,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (name ?? context.tr('adiclubMember'))
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email ?? context.tr('signInToSync'),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                if (signedIn) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    context.tr('editProfile'),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              if (signedIn) ...[
                _ProfileItem(
                  icon: Icons.receipt_long_outlined,
                  title: context.tr('myOrders'),
                  subtitle: context.tr('myOrdersSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                _ProfileItem(
                  icon: Icons.assignment_return_outlined,
                  title: context.tr('returnsRefunds'),
                  subtitle: context.tr('returnsRefundsSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/refund-status'),
                ),
                _ProfileItem(
                  icon: Icons.favorite_border,
                  title: context.tr('wishlist'),
                  subtitle: context.tr('wishlistSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/wishlist'),
                ),
                _ProfileItem(
                  icon: Icons.location_on_outlined,
                  title: context.tr('addresses'),
                  subtitle: context.tr('addressesSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/addresses'),
                ),
                _ProfileItem(
                  icon: Icons.credit_card_outlined,
                  title: context.tr('paymentMethods'),
                  subtitle: context.tr('paymentMethodsSubtitle'),
                  onTap: () =>
                      Navigator.pushNamed(context, '/payment-methods'),
                ),
                _ProfileItem(
                  icon: Icons.lock_outline,
                  title: context.tr('changePassword'),
                  subtitle: context.tr('changePasswordSubtitle'),
                  onTap: () =>
                      Navigator.pushNamed(context, '/change-password'),
                ),
              ],
              _ProfileItem(
                icon: Icons.support_agent_outlined,
                title: context.tr('helpSupport'),
                subtitle: context.tr('helpSupportSubtitle'),
                onTap: () {},
              ),
              _ProfileItem(
                icon: Icons.settings_outlined,
                title: context.tr('settings'),
                subtitle: context.tr('languageSubtitle'),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              if (!signedIn) ...[
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
                Text(
                  context.tr('signInToContinue'),
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(context.tr('signIn').toUpperCase()),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(context.tr('register').toUpperCase()),
                ),
              ],
              if (signedIn && isAdmin) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Divider(),
                ),
                Text(
                  context.tr('adminTools').toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                _ProfileItem(
                  icon: Icons.dashboard_outlined,
                  title: context.tr('adminDashboard'),
                  subtitle: context.tr('businessOverview'),
                  onTap: () => Navigator.pushNamed(context, '/admin/dashboard'),
                ),
                _ProfileItem(
                  icon: Icons.receipt_long_outlined,
                  title: context.tr('orderManagement'),
                  subtitle: context.tr('orderManagementSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/admin/orders'),
                ),
                _ProfileItem(
                  icon: Icons.inventory_2_outlined,
                  title: context.tr('productManagement'),
                  subtitle: context.tr('catalogInventory'),
                  onTap: () => Navigator.pushNamed(context, '/admin/products'),
                ),
                _ProfileItem(
                  icon: Icons.assignment_return_outlined,
                  title: context.tr('returnsRefunds'),
                  subtitle: context.tr('approveReturns'),
                  onTap: () =>
                      Navigator.pushNamed(context, '/admin/returns-refunds'),
                ),
                _ProfileItem(
                  icon: Icons.local_shipping_outlined,
                  title: context.tr('shipmentManagement'),
                  subtitle: context.tr('shipmentManagementSubtitle'),
                  onTap: () => Navigator.pushNamed(context, '/admin/shipments'),
                ),
              ],
              if (signedIn) ...[
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () async {
                    await storage.clear();
                    AppConfig.currentUserId = 0;
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (_) => false,
                    );
                  },
                  child: Text(context.tr('signOut').toUpperCase()),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Icon(icon, color: AppColors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
