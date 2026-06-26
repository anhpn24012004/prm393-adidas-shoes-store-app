import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/shipment_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class ShipmentService {
  final AuthStorage _authStorage = AuthStorage();

  Future<ShipmentDetail?> getUserShipment(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/orders/$orderId/shipment'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentTracking?> getUserTracking(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/orders/$orderId/tracking'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return ShipmentTracking.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(_errorMessage(response));
  }

  Future<List<ShipmentSummary>> getAdminShipments({
    String? status,
    String? keyword,
  }) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/admin/shipments').replace(
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (keyword != null && keyword.isNotEmpty) 'keyword': keyword,
      },
    );

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ShipmentSummary.fromJson(item)).toList();
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentDetail> getAdminShipmentDetail(int shipmentId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/admin/shipments/$shipmentId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentDetail> createShipment({
    required int orderId,
    required String carrier,
    required String trackingNumber,
    DateTime? estimatedDeliveryDate,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/admin/shipments'),
      headers: await _headers(),
      body: jsonEncode(
        CreateShipmentRequest(
          orderId: orderId,
          carrier: carrier,
          trackingNumber: trackingNumber,
          estimatedDeliveryDate: estimatedDeliveryDate,
          note: note,
        ).toJson(),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentDetail> updateShipmentStatus({
    required int shipmentId,
    required String status,
    String? note,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/admin/shipments/$shipmentId/status'),
      headers: await _headers(),
      body: jsonEncode(
        UpdateShipmentStatusRequest(status: status, note: note).toJson(),
      ),
    );

    if (response.statusCode == 200) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentDetail> updateShipmentTrackingInfo({
    required int shipmentId,
    required String carrier,
    required String trackingNumber,
    DateTime? estimatedDeliveryDate,
    String? note,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/shipments/$shipmentId/tracking-info',
      ),
      headers: await _headers(),
      body: jsonEncode(
        UpdateShipmentTrackingInfoRequest(
          carrier: carrier,
          trackingNumber: trackingNumber,
          estimatedDeliveryDate: estimatedDeliveryDate,
          note: note,
        ).toJson(),
      ),
    );

    if (response.statusCode == 200) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<ShipmentDetail> syncGhnStatus(int shipmentId) async {
    final response = await http.post(
      Uri.parse(
        '${ApiClient.baseUrl}/admin/shipments/$shipmentId/sync-ghn-status',
      ),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return ShipmentDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
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

  String _errorMessage(http.Response response) {
    if (response.statusCode == 401) {
      return 'Login required';
    }

    if (response.statusCode == 403) {
      return 'Admin access required';
    }

    if (response.statusCode == 404) {
      return 'Not found';
    }

    try {
      final data = jsonDecode(response.body);
      final message = data['message'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    } catch (_) {
      // ignore parse errors
    }

    return 'Request failed (${response.statusCode})';
  }
}
