class AiRecommendationRequest {
  final String gender;
  final double footLengthCm;
  final String footWidth;
  final String purpose;
  final double budget;
  final String favoriteColor;

  AiRecommendationRequest({
    required this.gender,
    required this.footLengthCm,
    required this.footWidth,
    required this.purpose,
    required this.budget,
    required this.favoriteColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'footLengthCm': footLengthCm,
      'footWidth': footWidth,
      'purpose': purpose,
      'budget': budget,
      'favoriteColor': favoriteColor,
    };
  }
}

class AiRecommendationResponse {
  final String recommendedSize;
  final String advice;

  AiRecommendationResponse({
    required this.recommendedSize,
    required this.advice,
  });

  factory AiRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return AiRecommendationResponse(
      recommendedSize: json['recommendedSize'] ?? '',
      advice: json['advice'] ?? '',
    );
  }
}
