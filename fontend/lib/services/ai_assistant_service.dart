import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/ai_recommendation_model.dart';

class AiAssistantService {
  static const String baseUrl = 'http://10.0.2.2:5209';

  Future<AiRecommendationResponse> getRecommendation(
      AiRecommendationRequest request,
      ) async {
    final url = Uri.parse(
      '$baseUrl/api/AiAssistant/shoe-recommendation',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AiRecommendationResponse.fromJson(data);
    }

    throw Exception('Không thể lấy tư vấn AI. Mã lỗi: ${response.statusCode}');
  }
}