import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/refund_request_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class RefundRequestService {
  final AuthStorage _authStorage = AuthStorage();

  Future<RefundRequestModel> createRefundRequest({
    required int orderId,
    required String reason,
    required double requestedAmount,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    String? customerNote,
    String? proofImageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/refund-requests'),
      headers: await _headers(),
      body: jsonEncode({
        'orderId': orderId,
        'reason': reason,
        'requestedAmount': requestedAmount,
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'bankAccountName': bankAccountName,
        'customerNote': customerNote,
        'proofImageUrl': proofImageUrl,
      }),
    );

    if (response.statusCode == 200) {
      return RefundRequestModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<List<RefundRequestModel>> getMyRefundRequests() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/refund-requests/my'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => RefundRequestModel.fromJson(item)).toList();
    }

    throw Exception(_message(response));
  }

  Future<RefundRequestModel> getMyRefundRequestById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/refund-requests/my/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return RefundRequestModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<List<RefundRequestModel>> getAdminRefundRequests() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/admin/refund-requests'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => RefundRequestModel.fromJson(item)).toList();
    }

    throw Exception(_message(response));
  }

  Future<RefundRequestModel> getAdminRefundRequestById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/admin/refund-requests/$id'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return RefundRequestModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<RefundRequestModel> approveRequest(
    int id, {
    String? adminNote,
  }) async {
    return _reviewRequest(
      id,
      'approve',
      adminNote: adminNote,
    );
  }

  Future<RefundRequestModel> rejectRequest(
    int id, {
    required String adminNote,
  }) async {
    return _reviewRequest(
      id,
      'reject',
      adminNote: adminNote,
    );
  }

  Future<RefundRequestModel> markAsRefunded(
    int id, {
    String? adminNote,
    String? refundTransactionNote,
  }) async {
    return _reviewRequest(
      id,
      'mark-refunded',
      adminNote: adminNote,
      refundTransactionNote: refundTransactionNote,
    );
  }

  Future<RefundRequestModel> _reviewRequest(
    int id,
    String action, {
    String? adminNote,
    String? refundTransactionNote,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/admin/refund-requests/$id/$action'),
      headers: await _headers(),
      body: jsonEncode({
        'adminNote': adminNote,
        'refundTransactionNote': refundTransactionNote,
      }),
    );

    if (response.statusCode == 200) {
      return RefundRequestModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authStorage.getToken();

    if (token == null) {
      throw Exception('Login required');
    }

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
      if (data is String) return data;
    } catch (_) {}

    return response.body.isEmpty
        ? 'Request failed (${response.statusCode})'
        : response.body;
  }
}
