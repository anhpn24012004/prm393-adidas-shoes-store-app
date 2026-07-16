import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static final Uri _supportEmail = Uri(
    scheme: 'mailto',
    path: 'support@adidas-shoes-store.com',
    queryParameters: {
      'subject': 'Adidas Shoes Store support',
    },
  );

  static final Uri _supportPhone = Uri(scheme: 'tel', path: '19001009');

  Future<void> _openUri(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('helpSupport'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _SectionTitle(text: context.tr('helpQuickActions')),
          _ActionTile(
            icon: Icons.receipt_long_outlined,
            title: context.tr('myOrders'),
            subtitle: context.tr('helpOrdersSubtitle'),
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          _ActionTile(
            icon: Icons.assignment_return_outlined,
            title: context.tr('returnsRefunds'),
            subtitle: context.tr('helpReturnsSubtitle'),
            onTap: () => Navigator.pushNamed(context, '/refund-status'),
          ),
          _ActionTile(
            icon: Icons.credit_card_outlined,
            title: context.tr('paymentMethods'),
            subtitle: context.tr('paymentMethodsSubtitle'),
            onTap: () => Navigator.pushNamed(context, '/payment-methods'),
          ),
          const SizedBox(height: 18),
          _SectionTitle(text: context.tr('helpTopics')),
          _HelpTopic(
            icon: Icons.payments_outlined,
            title: context.tr('helpPaymentTitle'),
            body: context.tr('helpPaymentBody'),
          ),
          _HelpTopic(
            icon: Icons.local_shipping_outlined,
            title: context.tr('helpShippingTitle'),
            body: context.tr('helpShippingBody'),
          ),
          _HelpTopic(
            icon: Icons.keyboard_return_outlined,
            title: context.tr('helpReturnTitle'),
            body: context.tr('helpReturnBody'),
          ),
          _HelpTopic(
            icon: Icons.lock_outline,
            title: context.tr('helpAccountTitle'),
            body: context.tr('helpAccountBody'),
          ),
          _HelpTopic(
            icon: Icons.email_outlined,
            title: context.tr('helpEmailTitle'),
            body: context.tr('helpEmailBody'),
          ),
          const SizedBox(height: 18),
          _SectionTitle(text: context.tr('contactSupport')),
          _ActionTile(
            icon: Icons.mail_outline,
            title: context.tr('emailSupport'),
            subtitle: 'support@adidas-shoes-store.com',
            onTap: () => _openUri(_supportEmail),
          ),
          _ActionTile(
            icon: Icons.phone_outlined,
            title: context.tr('hotlineSupport'),
            subtitle: '1900 1009',
            onTap: () => _openUri(_supportPhone),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: AppColors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _HelpTopic extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.fromLTRB(40, 0, 0, 14),
        leading: Icon(icon, color: AppColors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              body,
              style: const TextStyle(color: AppColors.muted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
