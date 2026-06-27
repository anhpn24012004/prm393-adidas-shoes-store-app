import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/return_refund_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class ReturnRefundService {
  final _authStorage = AuthStorage();

  Future<List<ReturnRequestModel>> getUserReturns(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/return-requests/my'),
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
      Uri.parse('${ApiClient.baseUrl}/admin/return-requests'),
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
    required String reason,
    String? customerNote,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/return-requests'),
      headers: await _headers(),
      body: jsonEncode({
        'orderId': orderId,
        'reason': reason,
        'customerNote': customerNote,
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'bankAccountName': bankAccountName,
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
      Uri.parse('${ApiClient.baseUrl}/return-requests/evidence'),
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
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/return-requests/$returnRequestId/$action',
      ),
      headers: await _headers(),
      body: jsonEncode({'adminNote': adminNote}),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<void> submitReturnShippingInfo({
    required int returnRequestId,
    required String returnCarrier,
    required String returnTrackingCode,
    String? returnShipmentNote,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiClient.baseUrl}/return-requests/$returnRequestId/shipping-info',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'returnCarrier': returnCarrier,
        'returnTrackingCode': returnTrackingCode,
        'returnShipmentNote': returnShipmentNote,
      }),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<void> markReturnReceived({
    required int returnRequestId,
    String? adminNote,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/return-requests/$returnRequestId/mark-received',
      ),
      headers: await _headers(),
      body: jsonEncode({'adminNote': adminNote}),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<void> inspectReturn({
    required int returnRequestId,
    required bool isRestockable,
    required int restockQuantity,
    String? inspectionNote,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/return-requests/$returnRequestId/inspect',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'isRestockable': isRestockable,
        'restockQuantity': restockQuantity,
        'inspectionNote': inspectionNote,
      }),
    );
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  Future<void> markReturnRefunded({
    required int returnRequestId,
    String? refundTransactionNote,
    String? adminNote,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/return-requests/$returnRequestId/mark-refunded',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'refundTransactionNote': refundTransactionNote,
        'adminNote': adminNote,
      }),
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
