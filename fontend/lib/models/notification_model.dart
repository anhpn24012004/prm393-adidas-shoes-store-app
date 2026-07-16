class NotificationModel {
  final int notificationId;
  final int? userId;
  final String? role;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? readAt;
  final int? relatedOrderId;
  final int? relatedPaymentId;
  final int? relatedShipmentId;
  final int? relatedRefundRequestId;
  final int? relatedReturnRequestId;
  final int? relatedProductId;
  final String? actionUrl;
  final String? metadataJson;

  const NotificationModel({
    required this.notificationId,
    this.userId,
    this.role,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.createdAt,
    this.readAt,
    this.relatedOrderId,
    this.relatedPaymentId,
    this.relatedShipmentId,
    this.relatedRefundRequestId,
    this.relatedReturnRequestId,
    this.relatedProductId,
    this.actionUrl,
    this.metadataJson,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? 0,
      userId: json['userId'],
      role: json['role'],
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      relatedOrderId: json['relatedOrderId'],
      relatedPaymentId: json['relatedPaymentId'],
      relatedShipmentId: json['relatedShipmentId'],
      relatedRefundRequestId: json['relatedRefundRequestId'],
      relatedReturnRequestId: json['relatedReturnRequestId'],
      relatedProductId: json['relatedProductId'],
      actionUrl: json['actionUrl'],
      metadataJson: json['metadataJson'],
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const NotificationListResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List? ?? [])
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return NotificationListResponse(
      items: items,
      totalCount: json['totalCount'] ?? items.length,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? items.length,
    );
  }
}
