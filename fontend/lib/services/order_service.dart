import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class OrderService {
  final AuthStorage _authStorage = AuthStorage();

  Future<OrderDetail> createOrder({
    required int addressId,
    required String paymentMethod,
    String? note,
    int? buyNowVariantId,
    int? buyNowQuantity,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/orders'),
      headers: await _headers(),
      body: jsonEncode(
        CreateOrderRequest(
          addressId: addressId,
          paymentMethod: paymentMethod,
          note: note,
          buyNowVariantId: buyNowVariantId,
          buyNowQuantity: buyNowQuantity,
        ).toJson(),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<List<OrderListItem>> getMyOrders() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/orders/my-orders'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => OrderListItem.fromJson(item)).toList();
    }

    throw Exception(_errorMessage(response));
  }

  Future<OrderDetail> getOrderDetail(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/orders/$orderId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return OrderDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<OrderDetail> cancelOrder(int orderId) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/orders/$orderId/cancel'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return OrderDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<OrderDetail> completeOrder(int orderId) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/orders/$orderId/complete'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return OrderDetail.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<CreateVnPayPaymentResponse> createVnPayPayment(int orderId) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/payments/vnpay/create'),
      headers: await _headers(),
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      return CreateVnPayPaymentResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<PaymentStatus> getPaymentStatus(int orderId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/payments/order/$orderId/status'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return PaymentStatus.fromJson(jsonDecode(response.body));
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

    try {
      final data = jsonDecode(response.body);
      final message = data['message'];

      if (message != null) {
        return message.toString();
      }
    } catch (_) {
      // Fall through to generic message.
    }

    return 'Request failed (${response.statusCode})';
  }
}
