import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/auth_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AuthService {
  final AuthStorage _storage = AuthStorage();

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleAuthResponse(response);
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/register'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'gender': gender,
        'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
      }),
    );
    return _handleAuthResponse(response);
  }

  Future<AuthSession> googleLogin(String idToken) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/google'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    return _handleAuthResponse(response);
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/forgot-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(_message(data, response.statusCode));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/reset-password'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'token': token,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(_message(data, response.statusCode));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw Exception('Please sign in again.');
    }

    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final data = _decode(response);
      throw Exception(_message(data, response.statusCode));
    }
  }

  Future<AuthSession> _handleAuthResponse(http.Response response) async {
    final data = _decode(response);
    if (response.statusCode != 200) {
      throw Exception(_message(data, response.statusCode));
    }

    final session = AuthSession.fromJson(data);
    await _storage.saveSession(
      token: session.token,
      userId: session.userId,
      fullName: session.fullName,
      email: session.email,
      role: session.role,
    );
    AppConfig.currentUserId = session.userId;
    return session;
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': response.body};
    }
  }

  String _message(Map<String, dynamic> data, int statusCode) {
    final message =
        data['message']?.toString() ?? 'Request failed ($statusCode)';
    final detail = data['detail']?.toString();
    final hint = data['hint']?.toString();

    final parts = <String>[message];
    if (detail != null && detail.isNotEmpty && detail != message) {
      parts.add(detail);
    }
    if (hint != null && hint.isNotEmpty && hint != detail) {
      parts.add(hint);
    }

    return parts.join(' ');
  }
}
