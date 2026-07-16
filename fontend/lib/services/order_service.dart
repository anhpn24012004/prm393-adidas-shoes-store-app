import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    required int toDistrictId,
    required String toWardCode,
    String? toProvinceName,
    String? toDistrictName,
    String? toWardName,
    required double shippingFee,
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
          toDistrictId: toDistrictId,
          toWardCode: toWardCode,
          toProvinceName: toProvinceName,
          toDistrictName: toDistrictName,
          toWardName: toWardName,
          shippingFee: shippingFee,
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
      body: jsonEncode({
        'orderId': orderId,
        'returnUrl': '${ApiClient.staticBaseUrl}/api/payments/vnpay-return',
      }),
    );

    if (response.statusCode == 200) {
      return CreateVnPayPaymentResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<CreatePayPalPaymentResponse> createPayPalPayment(int orderId) async {
    final frontendResultUrl = _frontendPaymentResultUrl();
    final returnUrl = Uri.parse(
      '${ApiClient.staticBaseUrl}/api/payments/paypal-return',
    ).replace(queryParameters: {'frontendReturnUrl': frontendResultUrl});
    final cancelUrl = Uri.parse(
      '${ApiClient.staticBaseUrl}/api/payments/paypal-cancel',
    ).replace(queryParameters: {'frontendReturnUrl': frontendResultUrl});

    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/payments/paypal/create'),
      headers: await _headers(),
      body: jsonEncode({
        'orderId': orderId,
        'returnUrl': returnUrl.toString(),
        'cancelUrl': cancelUrl.toString(),
      }),
    );

    if (response.statusCode == 200) {
      return CreatePayPalPaymentResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  String _frontendPaymentResultUrl() {
    if (kIsWeb && Uri.base.hasScheme && Uri.base.host.isNotEmpty) {
      final origin = Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.hasPort ? Uri.base.port : null,
      ).toString();

      return '$origin#/payment-result';
    }

    return 'http://localhost:52095/payment-result';
  }

  Future<SePayPaymentResponse> createSePayPayment(int orderId) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/payments/sepay/create'),
      headers: await _headers(),
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      return SePayPaymentResponse.fromJson(jsonDecode(response.body));
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
