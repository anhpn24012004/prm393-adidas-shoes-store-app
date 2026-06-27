class RefundRequestModel {
  final int refundRequestId;
  final int orderId;
  final int userId;
  final String requestCode;
  final String reason;
  final double requestedAmount;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final String? customerNote;
  final String status;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? refundedAt;
  final String? adminNote;
  final String? proofImageUrl;
  final String? refundTransactionNote;
  final String? orderCode;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? orderStatus;
  final double? finalAmount;
  final int? shipmentId;
  final String? shipmentStatus;
  final String? trackingCode;
  final String? ghnOrderCode;
  final DateTime? paidAt;
  final int? processedByAdminId;
  final String? processedByAdminName;
  final String? processedByAdminEmail;

  const RefundRequestModel({
    required this.refundRequestId,
    required this.orderId,
    required this.userId,
    required this.requestCode,
    required this.reason,
    required this.requestedAmount,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    this.customerNote,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.refundedAt,
    this.adminNote,
    this.proofImageUrl,
    this.refundTransactionNote,
    this.orderCode,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    this.finalAmount,
    this.shipmentId,
    this.shipmentStatus,
    this.trackingCode,
    this.ghnOrderCode,
    this.paidAt,
    this.processedByAdminId,
    this.processedByAdminName,
    this.processedByAdminEmail,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) {
    return RefundRequestModel(
      refundRequestId: json['refundRequestId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      requestCode: json['requestCode'] ?? '',
      reason: json['reason'] ?? '',
      requestedAmount: (json['requestedAmount'] as num? ?? 0).toDouble(),
      bankName: json['bankName'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      bankAccountName: json['bankAccountName'] ?? '',
      customerNote: json['customerNote'],
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      approvedAt: DateTime.tryParse(json['approvedAt']?.toString() ?? ''),
      rejectedAt: DateTime.tryParse(json['rejectedAt']?.toString() ?? ''),
      refundedAt: DateTime.tryParse(json['refundedAt']?.toString() ?? ''),
      adminNote: json['adminNote'],
      proofImageUrl: json['proofImageUrl'],
      refundTransactionNote: json['refundTransactionNote'],
      orderCode: json['orderCode'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      orderStatus: json['orderStatus'],
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      shipmentId: json['shipmentId'],
      shipmentStatus: json['shipmentStatus'],
      trackingCode: json['trackingCode'],
      ghnOrderCode: json['ghnOrderCode'],
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
      processedByAdminId: json['processedByAdminId'],
      processedByAdminName: json['processedByAdminName'],
      processedByAdminEmail: json['processedByAdminEmail'],
    );
  }

  bool get hasShipment => shipmentId != null || shipmentStatus?.isNotEmpty == true;
}
