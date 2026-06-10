import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/cart_model.dart';

class CartService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/cart';

  Future<int> addToCart({
    required int userId,
    required int variantId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'variantId': variantId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<CartModel> getCart(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return CartModel.fromJson(jsonDecode(response.body));
  }

  Future<int> getCartCount(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/count'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> updateQuantity(int cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/item/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> deleteItem(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/item/$cartItemId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }

    if (response.body.isEmpty) {
      return 0;
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> clearCart(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$userId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }

    if (response.body.isEmpty) {
      return 0;
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }
}
