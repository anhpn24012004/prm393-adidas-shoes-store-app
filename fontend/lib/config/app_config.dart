class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5209/api',
  );

  static const String signalRBaseUrl = String.fromEnvironment(
    'SIGNALR_BASE_URL',
    defaultValue: 'http://localhost:5209',
  );

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
