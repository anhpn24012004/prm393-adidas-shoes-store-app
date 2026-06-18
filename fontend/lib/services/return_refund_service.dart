import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/return_refund_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class ReturnRefundService {
  final _authStorage = AuthStorage();

  Future<List<ReturnRequestModel>> getUserReturns(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/returnrequests/user/$userId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => ReturnRequestModel.fromJson(item)).toList();
    }
    throw Exception(_message(response));
  }

  Future<List<ReturnRequestModel>> getAllReturns() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/returnrequests'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => ReturnRequestModel.fromJson(item)).toList();
    }
    throw Exception(_message(response));
  }

  Future<void> createReturn({
    required int orderId,
    required int userId,
    required String reason,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/returnrequests'),
      headers: await _headers(),
      body: jsonEncode({
        'orderId': orderId,
        'userId': userId,
        'reason': reason,
        'items': items,
      }),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<String> uploadEvidence({
    required List<int> bytes,
    required String fileName,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.baseUrl}/returnrequests/evidence'),
    );

    request.headers.addAll(await _headers(includeContentType: false));
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    final data = jsonDecode(response.body);
    return data['url']?.toString() ?? '';
  }

  Future<void> reviewReturn({
    required int returnRequestId,
    required bool approve,
    String? adminNote,
  }) async {
    final action = approve ? 'approve' : 'reject';
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/returnrequests/$returnRequestId/$action'),
      headers: await _headers(),
      body: jsonEncode(adminNote),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<List<RefundModel>> getRefundsByOrder(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/refunds/order/$orderId'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => RefundModel.fromJson(item)).toList();
    }
    throw Exception(_message(response));
  }

  Future<List<RefundModel>> getAllRefunds() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/refunds'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => RefundModel.fromJson(item)).toList();
    }
    throw Exception(_message(response));
  }

  Future<void> completeRefund(int refundId, String? transactionCode) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/refunds/$refundId/complete'),
      headers: await _headers(),
      body: jsonEncode({'transactionCode': transactionCode}),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<Map<String, String>> _headers({bool includeContentType = true}) async {
    final token = await _authStorage.getToken();
    return {
      if (includeContentType) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
