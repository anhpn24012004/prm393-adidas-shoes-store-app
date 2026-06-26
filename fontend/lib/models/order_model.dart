class CreateOrderRequest {
  final int addressId;
  final String paymentMethod;
  final String? note;
  final int? buyNowVariantId;
  final int? buyNowQuantity;
  final int toDistrictId;
  final String toWardCode;
  final String? toProvinceName;
  final String? toDistrictName;
  final String? toWardName;
  final double shippingFee;

  CreateOrderRequest({
    required this.addressId,
    required this.paymentMethod,
    this.note,
    this.buyNowVariantId,
    this.buyNowQuantity,
    required this.toDistrictId,
    required this.toWardCode,
    this.toProvinceName,
    this.toDistrictName,
    this.toWardName,
    required this.shippingFee,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'note': note,
      'buyNowVariantId': buyNowVariantId,
      'buyNowQuantity': buyNowQuantity,
      'toDistrictId': toDistrictId,
      'toWardCode': toWardCode,
      'toProvinceName': toProvinceName,
      'toDistrictName': toDistrictName,
      'toWardName': toWardName,
      'shippingFee': shippingFee,
    };
  }
}

class OrderListItem {
  final int orderId;
  final String orderCode;
  final double totalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final String status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? shipmentStatus;
  final String? ghnOrderCode;
  final String? trackingCode;
  final DateTime? expectedDeliveryTime;
  final DateTime? createdAt;
  final bool hasReturnRequest;
  final List<OrderItem> items;

  OrderListItem({
    required this.orderId,
    required this.orderCode,
    required this.totalAmount,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.shipmentStatus,
    this.ghnOrderCode,
    this.trackingCode,
    this.expectedDeliveryTime,
    this.createdAt,
    required this.hasReturnRequest,
    required this.items,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    return OrderListItem(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] as num? ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      shipmentStatus: json['shipmentStatus'],
      ghnOrderCode: json['ghnOrderCode'],
      trackingCode: json['trackingCode'] ?? json['trackingNumber'],
      expectedDeliveryTime: DateTime.tryParse(
        json['expectedDeliveryTime']?.toString() ?? '',
      ),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      hasReturnRequest: json['hasReturnRequest'] ?? false,
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}

class OrderDetail {
  final int orderId;
  final String orderCode;
  final double totalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final String status;
  final bool canReview;
  final String shippingAddress;
  final int? toDistrictId;
  final String? toWardCode;
  final String? toProvinceName;
  final String? toDistrictName;
  final String? toWardName;
  final String receiverName;
  final String receiverPhone;
  final String? note;
  final DateTime? createdAt;
  final PaymentInfo payment;
  final int? shipmentId;
  final String? shipmentStatus;
  final String? shippingProvider;
  final String? trackingCode;
  final String? ghnOrderCode;
  final DateTime? expectedDeliveryTime;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<OrderItem> items;

  OrderDetail({
    required this.orderId,
    required this.orderCode,
    required this.totalAmount,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.canReview,
    required this.shippingAddress,
    this.toDistrictId,
    this.toWardCode,
    this.toProvinceName,
    this.toDistrictName,
    this.toWardName,
    required this.receiverName,
    required this.receiverPhone,
    this.note,
    this.createdAt,
    required this.payment,
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

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] as num? ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] as num? ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] as num? ?? 0).toDouble(),
      status: json['status'] ?? '',
      canReview: json['canReview'] ?? false,
      shippingAddress: json['shippingAddress'] ?? '',
      toDistrictId: json['toDistrictId'],
      toWardCode: json['toWardCode'],
      toProvinceName: json['toProvinceName'],
      toDistrictName: json['toDistrictName'],
      toWardName: json['toWardName'],
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      note: json['note'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      payment: PaymentInfo.fromJson(json),
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

class OrderItem {
  final int orderItemId;
  final int variantId;
  final int productId;
  final String productName;
  final String? imageUrl;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.orderItemId,
    required this.variantId,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.size,
    required this.color,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['orderItemId'] ?? 0,
      variantId: json['variantId'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      imageUrl: json['imageUrl'],
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
      subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
    );
  }
}

class PaymentInfo {
  final int? paymentId;
  final String? paymentMethod;
  final double? paymentAmount;
  final String? paymentStatus;
  final String? transactionCode;
  final DateTime? paidAt;

  PaymentInfo({
    this.paymentId,
    this.paymentMethod,
    this.paymentAmount,
    this.paymentStatus,
    this.transactionCode,
    this.paidAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentId: json['paymentId'],
      paymentMethod: json['paymentMethod'],
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'],
      transactionCode: json['transactionCode'],
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
    );
  }
}

class CreateVnPayPaymentResponse {
  final String paymentUrl;

  CreateVnPayPaymentResponse({required this.paymentUrl});

  factory CreateVnPayPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreateVnPayPaymentResponse(paymentUrl: json['paymentUrl'] ?? '');
  }
}

class CreatePayPalPaymentResponse {
  final String approvalUrl;
  final String? paypalOrderId;

  CreatePayPalPaymentResponse({required this.approvalUrl, this.paypalOrderId});

  factory CreatePayPalPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePayPalPaymentResponse(
      approvalUrl: json['approvalUrl'] ?? '',
      paypalOrderId: json['paypalOrderId'],
    );
  }
}

class SePayPaymentResponse {
  final int orderId;
  final String qrCodeUrl;
  final String bankCode;
  final String bankAccountNumber;
  final String accountName;
  final String transferContent;
  final double amount;
  final String paymentStatus;
  final DateTime? expiresAt;

  SePayPaymentResponse({
    required this.orderId,
    required this.qrCodeUrl,
    required this.bankCode,
    required this.bankAccountNumber,
    required this.accountName,
    required this.transferContent,
    required this.amount,
    required this.paymentStatus,
    this.expiresAt,
  });

  factory SePayPaymentResponse.fromJson(Map<String, dynamic> json) {
    return SePayPaymentResponse(
      orderId: json['orderId'] ?? 0,
      qrCodeUrl: json['qrCodeUrl'] ?? '',
      bankCode: json['bankCode'] ?? '',
      bankAccountNumber: json['bankAccountNumber'] ?? '',
      accountName: json['accountName'] ?? '',
      transferContent: json['transferContent'] ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? '',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
    );
  }
}

class PaymentStatus {
  final int orderId;
  final String orderCode;
  final int paymentId;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double amount;
  final String? transactionCode;
  final DateTime? paidAt;
  final DateTime? expiresAt;
  final String? message;

  PaymentStatus({
    required this.orderId,
    required this.orderCode,
    required this.paymentId,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    this.transactionCode,
    this.paidAt,
    this.expiresAt,
    this.message,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      paymentId: json['paymentId'] ?? 0,
      orderStatus: json['orderStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      transactionCode: json['transactionCode'],
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      message: json['message'],
    );
  }

  bool get isSuccess =>
      paymentStatus == 'Success' || orderStatus == 'Paid';

  bool get isFailed =>
      paymentStatus == 'Failed' ||
      paymentStatus == 'Expired' ||
      orderStatus == 'Failed' ||
      orderStatus == 'Cancelled';
}
