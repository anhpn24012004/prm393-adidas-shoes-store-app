import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/ai_recommendation_model.dart';

class AiAssistantService {
  Future<AiRecommendationResponse> getRecommendation(
    AiRecommendationRequest request,
  ) async {
    final url = Uri.parse(
      '${AppConfig.apiBaseUrl}/AiAssistant/shoe-recommendation',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return AiRecommendationResponse.fromJson(data);
    }

    throw Exception(_message(response));
  }

  String _message(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}

    return 'Hệ thống tư vấn đang gặp sự cố. Vui lòng thử lại sau.';
  }
}
