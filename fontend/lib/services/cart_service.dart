import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl = "http://10.0.2.2:5209/api";

  Future<void> addToCart({
    required int userId,
    required int variantId,
    required int quantity,
  }) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "userId": userId,
        "variantId": variantId,
        "quantity": quantity,
      }),
    );
  }

  Future<dynamic> getCart(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
    );

    return jsonDecode(response.body);
  }

  Future<void> updateQuantity(
      int cartItemId,
      int quantity) async {
    await http.put(
      Uri.parse("$baseUrl/item/$cartItemId"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "quantity": quantity,
      }),
    );
  }

  Future<void> deleteItem(int cartItemId) async {
    await http.delete(
      Uri.parse("$baseUrl/item/$cartItemId"),
    );
  }
}