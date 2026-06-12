class ReturnRequestModel {
  final int returnRequestId;
  final int orderId;
  final int userId;
  final String reason;
  final String status;
  final DateTime? requestedAt;
  final String? adminNote;

  const ReturnRequestModel({
    required this.returnRequestId,
    required this.orderId,
    required this.userId,
    required this.reason,
    required this.status,
    this.requestedAt,
    this.adminNote,
  });

  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    return ReturnRequestModel(
      returnRequestId: json['returnRequestId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      requestedAt: DateTime.tryParse(json['requestedAt']?.toString() ?? ''),
      adminNote: json['adminNote'],
    );
  }
}

class RefundModel {
  final int refundId;
  final int returnRequestId;
  final int orderId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionCode;
  final DateTime? refundedAt;

  const RefundModel({
    required this.refundId,
    required this.returnRequestId,
    required this.orderId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionCode,
    this.refundedAt,
  });

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      refundId: json['refundId'] ?? 0,
      returnRequestId: json['returnRequestId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'],
      transactionCode: json['transactionCode'],
      refundedAt: DateTime.tryParse(json['refundedAt']?.toString() ?? ''),
    );
  }
}
