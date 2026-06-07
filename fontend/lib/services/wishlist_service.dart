import 'dart:convert';
import 'package:http/http.dart' as http;

class WishlistService {
  final String baseUrl =
      "http://10.0.2.2:5209/api";

  Future<void> addWishlist({
    required int userId,
    required int productId,
  }) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "userId": userId,
        "productId": productId,
      }),
    );
  }

  Future<List<dynamic>> getWishlist(
      int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
    );

    return jsonDecode(response.body);
  }

  Future<void> deleteWishlist(
      int wishlistId) async {
    await http.delete(
      Uri.parse("$baseUrl/$wishlistId"),
    );
  }
}