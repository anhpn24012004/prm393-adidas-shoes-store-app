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

  Future<void> saveSession({
    required String token,
    required int userId,
    required String fullName,
    required String email,
    required String role,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
    await preferences.setInt('userId', userId);
    await preferences.setString('fullName', fullName);
    await preferences.setString('email', email);
    await preferences.setString('role', role);
  }

  Future<void> saveProfile({
    required String fullName,
    required String email,
    required String role,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('fullName', fullName);
    await preferences.setString('email', email);
    await preferences.setString('role', role);
  }

  Future<int?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt('userId');
  }

  Future<String?> getFullName() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('fullName');
  }

  Future<String?> getEmail() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('email');
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    for (final key in [..._tokenKeys, 'userId', 'fullName', 'email', 'role']) {
      await preferences.remove(key);
    }
  }

  Future<String?> getRole() async {
    final preferences = await SharedPreferences.getInstance();
    final savedRole = preferences.getString('role');
    if (savedRole != null && savedRole.isNotEmpty) return savedRole;

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
