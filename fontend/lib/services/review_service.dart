import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import 'api_client.dart';

class ReviewService {
  Future<ReviewResponse> createReview(CreateReviewRequest request) async {
    final url = Uri.parse('${ApiClient.baseUrl}/reviews');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return ReviewResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
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
