import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = AppLanguageScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings').toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            context.tr('language').toUpperCase(),
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('languageSubtitle'),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          RadioListTile<String>(
            value: 'en',
            groupValue: localeController.locale.languageCode,
            title: Text(context.tr('english')),
            onChanged: (value) {
              if (value != null) localeController.setLanguage(value);
            },
          ),
          RadioListTile<String>(
            value: 'vi',
            groupValue: localeController.locale.languageCode,
            title: Text(context.tr('vietnamese')),
            onChanged: (value) {
              if (value != null) localeController.setLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}
