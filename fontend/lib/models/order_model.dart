class CreateOrderRequest {
  final int addressId;
  final String paymentMethod;
  final String? note;

  CreateOrderRequest({
    required this.addressId,
    required this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'paymentMethod': paymentMethod,
      'note': note,
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
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItem({
    required this.orderItemId,
    required this.variantId,
    required this.productName,
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
      productName: json['productName'] ?? '',
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
