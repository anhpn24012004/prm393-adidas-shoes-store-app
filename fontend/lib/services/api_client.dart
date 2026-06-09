import 'package:flutter/foundation.dart';

class ApiClient {
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5209/api';
    }

    return 'http://127.0.0.1:5209/api';
  }
}
