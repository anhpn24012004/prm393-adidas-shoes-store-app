import 'package:flutter/foundation.dart';

class AppConfig {
  /// Set your PC LAN IP when testing on a physical phone, e.g. '192.168.1.10'.
  static const String? deviceHostOverride = null;

  static String get apiHost {
    if (deviceHostOverride != null && deviceHostOverride!.isNotEmpty) {
      return deviceHostOverride!;
    }

    if (kIsWeb) {
      return 'localhost';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '10.0.2.2';
      default:
        return 'localhost';
    }
  }

  static String get apiBaseUrl => 'http://$apiHost:5209/api';

  static String get staticBaseUrl => 'http://$apiHost:5209';

  static String resolveImageUrl(String imageUrl) {
    final trimmed = imageUrl.trim();

    if (trimmed.isEmpty ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://')) {
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return '$staticBaseUrl$trimmed';
    }

    return '$staticBaseUrl/$trimmed';
  }

  static int currentUserId = 0;
}
