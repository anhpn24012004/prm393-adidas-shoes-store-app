class CreateOrderRequest {
  final int addressId;
  final String paymentMethod;
  final String? note;
  final int? buyNowVariantId;
  final int? buyNowQuantity;

  CreateOrderRequest({
    required this.addressId,
    required this.paymentMethod,
    this.note,
    this.buyNowVariantId,
    this.buyNowQuantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'note': note,
      'buyNowVariantId': buyNowVariantId,
      'buyNowQuantity': buyNowQuantity,
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
  final String receiverName;
  final String receiverPhone;
  final String? note;
  final DateTime? createdAt;
  final PaymentInfo payment;
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
    required this.receiverName,
    required this.receiverPhone,
    this.note,
    this.createdAt,
    required this.payment,
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
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      note: json['note'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      payment: PaymentInfo.fromJson(json),
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

  CreatePayPalPaymentResponse({
    required this.approvalUrl,
    this.paypalOrderId,
  });

  factory CreatePayPalPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CreatePayPalPaymentResponse(
      approvalUrl: json['approvalUrl'] ?? '',
      paypalOrderId: json['paypalOrderId'],
    );
  }
}

class QrPaymentResponse {
  final String qrImageUrl;
  final String bankBin;
  final String accountNo;
  final String accountName;
  final String transferContent;
  final double amount;

  QrPaymentResponse({
    required this.qrImageUrl,
    required this.bankBin,
    required this.accountNo,
    required this.accountName,
    required this.transferContent,
    required this.amount,
  });

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrPaymentResponse(
      qrImageUrl: json['qrImageUrl'] ?? '',
      bankBin: json['bankBin'] ?? '',
      accountNo: json['accountNo'] ?? '',
      accountName: json['accountName'] ?? '',
      transferContent: json['transferContent'] ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
    );
  }
}

class VisaPaymentRequest {
  final int orderId;
  final String cardNumber;
  final String cardHolderName;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  VisaPaymentRequest({
    required this.orderId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'cvv': cvv,
    };
  }
}

class PaymentStatus {
  final int orderId;
  final String orderCode;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double amount;
  final String? transactionCode;
  final DateTime? paidAt;

  PaymentStatus({
    required this.orderId,
    required this.orderCode,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    this.transactionCode,
    this.paidAt,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      orderId: json['orderId'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      transactionCode: json['transactionCode'],
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
    );
  }
}
