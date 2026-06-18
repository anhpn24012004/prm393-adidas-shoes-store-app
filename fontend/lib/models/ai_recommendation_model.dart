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
  final List<AiRecommendedProduct> recommendedProducts;

  AiRecommendationResponse({
    required this.recommendedSize,
    required this.advice,
    required this.recommendedProducts,
  });

  factory AiRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return AiRecommendationResponse(
      recommendedSize: json['recommendedSize'] ?? '',
      advice: json['advice'] ?? '',
      recommendedProducts: ((json['recommendedProducts'] ?? []) as List)
          .map((item) => AiRecommendedProduct.fromJson(item))
          .toList(),
    );
  }
}

class AiRecommendedProduct {
  final int productId;
  final int variantId;
  final String productName;
  final String? categoryName;
  final String? mainImageUrl;
  final String size;
  final String color;
  final double price;
  final int stockQuantity;
  final String reason;

  AiRecommendedProduct({
    required this.productId,
    required this.variantId,
    required this.productName,
    this.categoryName,
    this.mainImageUrl,
    required this.size,
    required this.color,
    required this.price,
    required this.stockQuantity,
    required this.reason,
  });

  factory AiRecommendedProduct.fromJson(Map<String, dynamic> json) {
    return AiRecommendedProduct(
      productId: json['productId'] ?? 0,
      variantId: json['variantId'] ?? 0,
      productName: json['productName'] ?? '',
      categoryName: json['categoryName'],
      mainImageUrl: json['mainImageUrl'],
      size: json['size']?.toString() ?? '',
      color: json['color'] ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
}
