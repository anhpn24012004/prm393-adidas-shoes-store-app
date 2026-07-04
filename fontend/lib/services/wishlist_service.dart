import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/wishlist_model.dart';
import 'auth_storage.dart';

class WishlistService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/wishlist';
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in again.');
    }

    return {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<int> addWishlist({
    required int productId,
    int? variantId,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'productId': productId,
        'variantId': variantId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<List<WishlistModel>> getWishlist() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => WishlistModel.fromJson(item)).toList();
  }

  Future<int> getWishlistCount() async {
    final response = await http.get(
      Uri.parse('$baseUrl/my/count'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<int> deleteWishlist(int wishlistId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$wishlistId'),
      headers: await _authHeaders(),
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

  Future<int> clearWishlist() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/my'),
      headers: await _authHeaders(),
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
