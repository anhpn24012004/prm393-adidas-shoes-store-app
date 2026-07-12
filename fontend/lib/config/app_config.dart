import 'package:flutter/foundation.dart';

class AppConfig {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _signalRBaseUrlOverride = String.fromEnvironment(
    'SIGNALR_BASE_URL',
  );
  static const String _serverPort = '5209';

  static String get _serverHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }

    return 'localhost';
  }

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _apiBaseUrlOverride;
    }

    return 'http://$_serverHost:$_serverPort/api';
  }

  static String get signalRBaseUrl {
    if (_signalRBaseUrlOverride.isNotEmpty) {
      return _signalRBaseUrlOverride;
    }

    return 'http://$_serverHost:$_serverPort';
  }

  static String get staticBaseUrl {
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }

    return signalRBaseUrl;
  }

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
