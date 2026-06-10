import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final String baseUrl = '${AppConfig.apiBaseUrl}/wishlist';

  Future<int> addWishlist({
    required int userId,
    required int productId,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(response.body);
    }

    final data = jsonDecode(response.body);
    return data['totalItems'] ?? 0;
  }

  Future<List<WishlistModel>> getWishlist(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final List data = jsonDecode(response.body);
    return data.map((item) => WishlistModel.fromJson(item)).toList();
  }

  Future<int> getWishlistCount(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/count'),
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

  Future<int> clearWishlist(int userId) async {
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
