import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class ReviewService {
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<ReviewResponse> createReview(CreateReviewRequest request) async {
    final url = Uri.parse('${ApiClient.baseUrl}/reviews');

    final response = await http.post(
      url,
      headers: await _authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body.replaceAll('"', ''));
  }

  Future<ReviewResponse?> getUserReview({
    required int productId,
  }) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/reviews/my/product/$productId',
    );

    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(jsonDecode(response.body));
    }

    if (response.statusCode == 404) {
      return null;
    }

    throw Exception(response.body.replaceAll('"', ''));
  }

  Future<ReviewResponse> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    final url = Uri.parse('${ApiClient.baseUrl}/reviews/$reviewId');

    final response = await http.put(
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'rating': rating,
        'comment': comment,
      }),
    );

    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body.replaceAll('"', ''));
  }

  Future<List<ReviewResponse>> getReviewsByProductId(int productId) async {
    final url = Uri.parse('${ApiClient.baseUrl}/reviews/product/$productId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ReviewResponse.fromJson(e)).toList();
    }

    throw Exception(response.body);
  }
}
