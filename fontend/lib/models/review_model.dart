class CreateReviewRequest {
  final int userId;
  final int productId;
  final int rating;
  final String comment;

  CreateReviewRequest({
    required this.userId,
    required this.productId,
    required this.rating,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'productId': productId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class ReviewResponse {
  final int reviewId;
  final int userId;
  final int productId;
  final int rating;
  final String? comment;
  final String? createdAt;
  final int editCount;
  final bool canEdit;

  ReviewResponse({
    required this.reviewId,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    this.createdAt,
    required this.editCount,
    required this.canEdit,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      reviewId: json['reviewId'] ?? 0,
      userId: json['userId'] ?? 0,
      productId: json['productId'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: json['createdAt'],
      editCount: json['editCount'] ?? 0,
      canEdit: json['canEdit'] ?? false,
    );
  }
}
