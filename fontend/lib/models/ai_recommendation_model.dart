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
  final bool success;
  final bool isAiGenerated;
  final bool colorFallback;
  final bool budgetFallback;
  final int recommendedSize;
  final String sizeAdvice;
  final String summary;
  final String? fitWarning;
  final List<String> warnings;
  final List<String> buyingTips;
  final List<AiRecommendedProduct> recommendations;

  AiRecommendationResponse({
    required this.success,
    required this.isAiGenerated,
    required this.colorFallback,
    required this.budgetFallback,
    required this.recommendedSize,
    required this.sizeAdvice,
    required this.summary,
    required this.fitWarning,
    required this.warnings,
    required this.buyingTips,
    required this.recommendations,
  });

  factory AiRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final productsJson =
        json['recommendations'] ?? json['recommendedProducts'] ?? const [];

    return AiRecommendationResponse(
      success: json['success'] as bool? ?? true,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      colorFallback: json['colorFallback'] as bool? ?? false,
      budgetFallback: json['budgetFallback'] as bool? ?? false,
      recommendedSize: _parseInt(json['recommendedSize']),
      sizeAdvice:
          json['sizeAdvice']?.toString() ?? json['advice']?.toString() ?? '',
      summary: json['summary']?.toString() ?? json['advice']?.toString() ?? '',
      fitWarning: json['fitWarning']?.toString(),
      warnings: (json['warnings'] as List? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      buyingTips: (json['buyingTips'] as List? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      recommendations: (productsJson as List)
          .map((item) => AiRecommendedProduct.fromJson(item))
          .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString().replaceAll('EU', '') ?? '') ?? 0;
  }
}

class AiRecommendedProduct {
  final int productId;
  final int variantId;
  final String productName;
  final String? categoryName;
  final String? imageUrl;
  final String size;
  final String color;
  final double price;
  final int stockQuantity;
  final int matchScore;
  final String reason;
  final List<String> reasonTags;

  AiRecommendedProduct({
    required this.productId,
    required this.variantId,
    required this.productName,
    this.categoryName,
    this.imageUrl,
    required this.size,
    required this.color,
    required this.price,
    required this.stockQuantity,
    required this.matchScore,
    required this.reason,
    required this.reasonTags,
  });

  factory AiRecommendedProduct.fromJson(Map<String, dynamic> json) {
    return AiRecommendedProduct(
      productId: json['productId'] as int? ?? 0,
      variantId: json['variantId'] as int? ?? 0,
      productName: json['productName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString(),
      imageUrl:
          json['mainImageUrl']?.toString() ?? json['imageUrl']?.toString(),
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      matchScore: (json['matchScore'] as num? ?? 0).round(),
      reason: json['reason']?.toString() ?? '',
      reasonTags: (json['reasonTags'] as List? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
    );
  }
}
