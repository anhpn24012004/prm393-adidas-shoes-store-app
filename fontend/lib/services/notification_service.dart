import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notification_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class NotificationService {
  final _authStorage = AuthStorage();

  Future<List<NotificationModel>> getMyNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl}/notifications/my',
    ).replace(queryParameters: {'page': '$page', 'pageSize': '$pageSize'});

    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return NotificationListResponse.fromJson(data).items;
    }

    throw Exception(_message(response));
  }

  Future<int> getUnreadCount() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/notifications/unread-count'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['count'] as int? ?? 0;
    }

    throw Exception(_message(response));
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/notifications/$notificationId/read'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }
  }

  Future<void> markAllAsRead() async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/notifications/read-all'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }
  }

  Future<List<NotificationModel>> getAdminNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl}/admin/notifications',
    ).replace(queryParameters: {'page': '$page', 'pageSize': '$pageSize'});

    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return NotificationListResponse.fromJson(data).items;
    }

    throw Exception(_message(response));
  }

  Future<Map<String, dynamic>> broadcastMarketingNotification({
    required String title,
    required String message,
    required String type,
    String targetRole = 'Customer',
    int? relatedProductId,
    String? actionUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/admin/notifications/broadcast'),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'message': message,
        'type': type,
        'targetRole': targetRole,
        'relatedProductId': relatedProductId,
        'actionUrl': actionUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _message(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    return response.body.isEmpty
        ? 'Request failed (${response.statusCode})'
        : response.body;
  }
}
