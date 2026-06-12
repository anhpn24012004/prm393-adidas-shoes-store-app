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
  final List<OrderItem> items;

  const AdminOrderDetail({
    required this.summary,
    required this.shippingAddress,
    this.note,
    required this.items,
  });

  factory AdminOrderDetail.fromJson(Map<String, dynamic> json) {
    return AdminOrderDetail(
      summary: AdminOrderSummary.fromJson(json),
      shippingAddress: json['shippingAddress'] ?? '',
      note: json['note'],
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}
