import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class CartService {
  String get baseUrl => '${ApiClient.baseUrl}/cart';
  final AuthStorage _authStorage = AuthStorage();

  Future<int> addToCart({
    required int userId,
    required int variantId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _headers(),
      body: jsonEncode({
        'variantId': variantId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_message(response));
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<CartModel> getCart(int userId) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    return CartModel.fromJson(jsonDecode(response.body));
  }

  Future<int> getCartCount(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/count'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> updateQuantity(int cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/item/$cartItemId'),
      headers: await _headers(),
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> deleteItem(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/item/$cartItemId'),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response));
    }

    if (response.body.isEmpty) {
      return 0;
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> clearCart(int userId) async {
    final response = await http.delete(
      Uri.parse(baseUrl),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response));
    }

    if (response.body.isEmpty) {
      return 0;
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  String _message(http.Response response) {
    if (response.statusCode == 401) {
      return 'Login required';
    }

    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    return 'Request failed (${response.statusCode})';
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
}
