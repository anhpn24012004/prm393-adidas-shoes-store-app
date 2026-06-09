import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const List<String> _tokenKeys = [
    'token',
    'jwtToken',
    'accessToken',
    'authToken',
  ];

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();

    for (final key in _tokenKeys) {
      final token = preferences.getString(key);

      if (token != null && token.trim().isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  Future<String?> getRole() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    try {
      final parts = token.split('.');

      if (parts.length < 2) {
        return null;
      }

      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalizedPayload));
      final claims = jsonDecode(payloadJson) as Map<String, dynamic>;

      return claims['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']
              ?.toString() ??
          claims['role']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<bool> isAdmin() async {
    return await getRole() == 'Admin';
  }
}
