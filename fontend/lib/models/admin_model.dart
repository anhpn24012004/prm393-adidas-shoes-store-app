import 'order_model.dart';

class AdminDashboardModel {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int completedOrders;
  final int totalRefundRequests;
  final int totalReviews;

  const AdminDashboardModel({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalRefundRequests,
    required this.totalReviews,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      inactiveUsers: json['inactiveUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num? ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      totalRefundRequests: json['totalRefundRequests'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}

class AdminOrderSummary {
  final int orderId;
  final String orderCode;
  final String customerName;
  final String customerEmail;
  final String receiverName;
  final String receiverPhone;
  final double finalAmount;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? createdAt;

  const AdminOrderSummary({
    required this.orderId,
    required this.orderCode,
    required this.customerName,
    required this.customerEmail,
    required this.receiverName,
    required this.receiverPhone,
    required this.finalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
  });

  factory AdminOrderSummary.fromJson(Map<String, dynamic> json) {
    return AdminOrderSummary(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      finalAmount: (json['finalAmount'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }
}

class AdminOrderDetail {
  final AdminOrderSummary summary;
  final String shippingAddress;
  final String? note;
  final int? shipmentId;
  final String? shipmentStatus;
  final String? shippingProvider;
  final String? trackingCode;
  final String? ghnOrderCode;
  final DateTime? expectedDeliveryTime;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<OrderItem> items;

  const AdminOrderDetail({
    required this.summary,
    required this.shippingAddress,
    this.note,
    this.shipmentId,
    this.shipmentStatus,
    this.shippingProvider,
    this.trackingCode,
    this.ghnOrderCode,
    this.expectedDeliveryTime,
    this.shippedAt,
    this.deliveredAt,
    required this.items,
  });

  factory AdminOrderDetail.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetail(
      summary: AdminOrderSummary.fromJson(json),
      shippingAddress: json['shippingAddress'] ?? '',
      note: json['note'],
      shipmentId: json['shipmentId'],
      shipmentStatus: json['shipmentStatus'],
      shippingProvider: json['shippingProvider'] ?? json['carrier'],
      trackingCode: json['trackingCode'] ?? json['trackingNumber'],
      ghnOrderCode: json['ghnOrderCode'],
      expectedDeliveryTime: DateTime.tryParse(
        json['expectedDeliveryTime']?.toString() ?? '',
      ),
      shippedAt: DateTime.tryParse(json['shippedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class AdminUserSummary {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final String roleName;
  final bool isActive;
  final DateTime? createdAt;
  final int orderCount;
  final int returnRequestCount;

  const AdminUserSummary({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    required this.roleName,
    required this.isActive,
    this.createdAt,
    required this.orderCount,
    required this.returnRequestCount,
  });

  factory AdminUserSummary.fromJson(Map<String, dynamic> json) {
    return AdminUserSummary(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      roleName: json['roleName'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      orderCount: json['orderCount'] ?? 0,
      returnRequestCount: json['returnRequestCount'] ?? 0,
    );
  }
}
