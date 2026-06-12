import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AdminService {
  final _storage = AuthStorage();

  Future<AdminDashboardModel> getDashboard() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/admin/dashboard'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return AdminDashboardModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(_message(response));
  }

  Future<List<AdminOrderSummary>> getOrders({
    String? status,
    String? keyword,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/admin/orders').replace(
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );
    final response = await http.get(uri, headers: await _headers());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => AdminOrderSummary.fromJson(item)).toList();
    }
    throw Exception(_message(response));
  }

  Future<AdminOrderDetail> getOrder(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/admin/orders/$orderId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return AdminOrderDetail.fromJson(jsonDecode(response.body));
    }
    throw Exception(_message(response));
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/admin/orders/$orderId/status'),
      headers: await _headers(),
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Admin login required');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _message(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return 'Request failed (${response.statusCode})';
  }
}
