class ReturnRequestModel {
  final int returnRequestId;
  final String requestCode;
  final int orderId;
  final String orderCode;
  final int userId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String reason;
  final String? customerNote;
  final String status;
  final DateTime? requestedAt;
  final String? adminNote;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
  final double requestedAmount;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? returnCarrier;
  final String? returnTrackingCode;
  final String? returnShipmentNote;
  final DateTime? returnShippedAt;
  final DateTime? returnReceivedAt;
  final String? inspectionNote;
  final bool? isRestockable;
  final int? restockQuantity;
  final String? refundTransactionNote;
  final DateTime? refundedAt;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? orderStatus;
  final List<ReturnItemModel> items;
  final ShopReturnAddressModel? shopReturnAddress;

  const ReturnRequestModel({
    required this.returnRequestId,
    required this.requestCode,
    required this.orderId,
    required this.orderCode,
    required this.userId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.reason,
    this.customerNote,
    required this.status,
    this.requestedAt,
    this.adminNote,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.requestedAmount,
    this.approvedAt,
    this.rejectedAt,
    this.returnCarrier,
    this.returnTrackingCode,
    this.returnShipmentNote,
    this.returnShippedAt,
    this.returnReceivedAt,
    this.inspectionNote,
    this.isRestockable,
    this.restockQuantity,
    this.refundTransactionNote,
    this.refundedAt,
    this.paymentMethod,
    this.paymentStatus,
    this.orderStatus,
    required this.items,
    this.shopReturnAddress,
  });

  factory ReturnRequestModel.fromJson(Map<String, dynamic> json) {
    return ReturnRequestModel(
      returnRequestId: json['returnRequestId'] ?? 0,
      requestCode: json['requestCode'] ?? '',
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      userId: json['userId'] ?? 0,
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      reason: json['reason'] ?? '',
      customerNote: json['customerNote'],
      status: json['status'] ?? '',
      requestedAt: DateTime.tryParse(json['requestedAt']?.toString() ?? ''),
      adminNote: json['adminNote'],
      bankName: json['bankName'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      bankAccountName: json['bankAccountName'] ?? '',
      requestedAmount: (json['requestedAmount'] as num? ?? 0).toDouble(),
      approvedAt: DateTime.tryParse(json['approvedAt']?.toString() ?? ''),
      rejectedAt: DateTime.tryParse(json['rejectedAt']?.toString() ?? ''),
      returnCarrier: json['returnCarrier'],
      returnTrackingCode: json['returnTrackingCode'],
      returnShipmentNote: json['returnShipmentNote'],
      returnShippedAt:
          DateTime.tryParse(json['returnShippedAt']?.toString() ?? ''),
      returnReceivedAt:
          DateTime.tryParse(json['returnReceivedAt']?.toString() ?? ''),
      inspectionNote: json['inspectionNote'],
      isRestockable: json['isRestockable'],
      restockQuantity: json['restockQuantity'],
      refundTransactionNote: json['refundTransactionNote'],
      refundedAt: DateTime.tryParse(json['refundedAt']?.toString() ?? ''),
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      orderStatus: json['orderStatus'],
      items: (json['items'] as List? ?? [])
          .map((item) => ReturnItemModel.fromJson(item))
          .toList(),
      shopReturnAddress: json['shopReturnAddress'] == null
          ? null
          : ShopReturnAddressModel.fromJson(json['shopReturnAddress']),
    );
  }
}

class ReturnItemModel {
  final int returnItemId;
  final int orderItemId;
  final int productId;
  final int productVariantId;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final double refundAmount;

  const ReturnItemModel({
    required this.returnItemId,
    required this.orderItemId,
    required this.productId,
    required this.productVariantId,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.refundAmount,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnItemModel(
      returnItemId: json['returnItemId'] ?? 0,
      orderItemId: json['orderItemId'] ?? 0,
      productId: json['productId'] ?? 0,
      productVariantId: json['productVariantId'] ?? 0,
      productName: json['productName'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      refundAmount: (json['refundAmount'] as num? ?? 0).toDouble(),
    );
  }
}

class ShopReturnAddressModel {
  final String shopName;
  final String phone;
  final String address;
  final String? wardName;
  final String? districtName;
  final String? provinceName;

  const ShopReturnAddressModel({
    required this.shopName,
    required this.phone,
    required this.address,
    this.wardName,
    this.districtName,
    this.provinceName,
  });

  factory ShopReturnAddressModel.fromJson(Map<String, dynamic> json) {
    return ShopReturnAddressModel(
      shopName: json['shopName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      wardName: json['wardName'],
      districtName: json['districtName'],
      provinceName: json['provinceName'],
    );
  }

  String get fullAddress {
    return [
      address,
      wardName,
      districtName,
      provinceName,
    ].where((part) => part != null && part!.trim().isNotEmpty).join(', ');
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
