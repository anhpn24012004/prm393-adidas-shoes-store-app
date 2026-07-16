class AppConfig {
  static const String _productionBackendBaseUrl =
      'https://api-adidas.teaviafarm.io.vn';
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _signalRBaseUrlOverride = String.fromEnvironment(
    'SIGNALR_BASE_URL',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) {
      return _withApiPath(_apiBaseUrlOverride);
    }

    return '$_productionBackendBaseUrl/api';
  }

  static String get signalRBaseUrl {
    if (_signalRBaseUrlOverride.isNotEmpty) {
      return _trimTrailingSlash(_signalRBaseUrlOverride);
    }

    return _productionBackendBaseUrl;
  }

  static String get staticBaseUrl {
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }

    return signalRBaseUrl;
  }

  static String _withApiPath(String baseUrl) {
    final trimmed = _trimTrailingSlash(baseUrl);

    if (trimmed.endsWith('/api')) {
      return trimmed;
    }

    return '$trimmed/api';
  }

  static String _trimTrailingSlash(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
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
