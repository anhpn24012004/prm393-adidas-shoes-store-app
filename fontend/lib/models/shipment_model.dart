class ShipmentSummary {
  final int? shipmentId;
  final int? orderId;
  final String? orderCode;
  final String? customerName;
  final String? customerEmail;
  final String? receiverName;
  final String? receiverPhone;
  final String? carrier;
  final String? trackingNumber;
  final String? ghnOrderCode;
  final String? shipmentStatus;
  final String? orderStatus;
  final String? paymentStatus;
  final double? finalAmount;
  final DateTime? estimatedDeliveryDate;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  ShipmentSummary({
    this.shipmentId,
    this.orderId,
    this.orderCode,
    this.customerName,
    this.customerEmail,
    this.receiverName,
    this.receiverPhone,
    this.carrier,
    this.trackingNumber,
    this.ghnOrderCode,
    this.shipmentStatus,
    this.orderStatus,
    this.paymentStatus,
    this.finalAmount,
    this.estimatedDeliveryDate,
    this.shippedAt,
    this.deliveredAt,
  });

  factory ShipmentSummary.fromJson(Map<String, dynamic> json) {
    return ShipmentSummary(
      shipmentId: json['shipmentId'],
      orderId: json['orderId'],
      orderCode: json['orderCode'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      carrier: json['carrier'] ?? json['shippingProvider'],
      trackingNumber: json['trackingNumber'] ?? json['trackingCode'],
      ghnOrderCode: json['ghnOrderCode'],
      shipmentStatus: json['shipmentStatus'] ?? json['status'],
      orderStatus: json['orderStatus'],
      paymentStatus: json['paymentStatus'],
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      estimatedDeliveryDate: DateTime.tryParse(
        json['estimatedDeliveryDate']?.toString() ?? '',
      ),
      shippedAt: DateTime.tryParse(json['shippedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
    );
  }
}

class ShipmentDetail {
  final int? shipmentId;
  final int? orderId;
  final String? orderCode;
  final String? orderStatus;
  final String? shipmentStatus;
  final String? carrier;
  final String? trackingNumber;
  final String? ghnOrderCode;
  final DateTime? estimatedDeliveryDate;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? receiverName;
  final String? receiverPhone;
  final String? shippingAddress;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? transactionCode;
  final DateTime? paidAt;
  final double? totalAmount;
  final double? shippingFee;
  final double? discountAmount;
  final double? finalAmount;
  final String? note;
  final bool manualOverrideEnabled;
  final List<ShipmentItem> items;

  ShipmentDetail({
    this.shipmentId,
    this.orderId,
    this.orderCode,
    this.orderStatus,
    this.shipmentStatus,
    this.carrier,
    this.trackingNumber,
    this.ghnOrderCode,
    this.estimatedDeliveryDate,
    this.shippedAt,
    this.deliveredAt,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.paymentMethod,
    this.paymentStatus,
    this.transactionCode,
    this.paidAt,
    this.totalAmount,
    this.shippingFee,
    this.discountAmount,
    this.finalAmount,
    this.note,
    this.manualOverrideEnabled = false,
    this.items = const [],
  });

  factory ShipmentDetail.fromJson(Map<String, dynamic> json) {
    return ShipmentDetail(
      shipmentId: json['shipmentId'],
      orderId: json['orderId'],
      orderCode: json['orderCode'],
      orderStatus: json['orderStatus'],
      shipmentStatus: json['shipmentStatus'] ?? json['status'],
      carrier: json['carrier'] ?? json['shippingProvider'],
      trackingNumber: json['trackingNumber'] ?? json['trackingCode'],
      ghnOrderCode: json['ghnOrderCode'],
      estimatedDeliveryDate: DateTime.tryParse(
        json['estimatedDeliveryDate']?.toString() ?? '',
      ),
      shippedAt: DateTime.tryParse(json['shippedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      shippingAddress: json['shippingAddress'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      customerPhone: json['customerPhone'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      transactionCode: json['transactionCode'],
      paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      shippingFee: (json['shippingFee'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalAmount: (json['finalAmount'] as num?)?.toDouble(),
      note: json['note'],
      manualOverrideEnabled: json['manualOverrideEnabled'] == true,
      items: (json['orderItems'] as List? ?? json['items'] as List? ?? [])
          .map((item) => ShipmentItem.fromJson(item))
          .toList(),
    );
  }
}

class ShipmentTracking {
  final int? orderId;
  final String? orderCode;
  final String? orderStatus;
  final int? shipmentId;
  final String? shipmentStatus;
  final String? carrier;
  final String? trackingNumber;
  final String? ghnOrderCode;
  final String? rawGhnStatus;
  final DateTime? estimatedDeliveryDate;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? receiverName;
  final String? receiverPhone;
  final String? shippingAddress;

  ShipmentTracking({
    this.orderId,
    this.orderCode,
    this.orderStatus,
    this.shipmentId,
    this.shipmentStatus,
    this.carrier,
    this.trackingNumber,
    this.ghnOrderCode,
    this.rawGhnStatus,
    this.estimatedDeliveryDate,
    this.shippedAt,
    this.deliveredAt,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
  });

  factory ShipmentTracking.fromJson(Map<String, dynamic> json) {
    return ShipmentTracking(
      orderId: json['orderId'],
      orderCode: json['orderCode'],
      orderStatus: json['orderStatus'],
      shipmentId: json['shipmentId'],
      shipmentStatus: json['shipmentStatus'],
      carrier: json['carrier'],
      trackingNumber: json['trackingNumber'],
      ghnOrderCode: json['ghnOrderCode'],
      rawGhnStatus: json['rawGhnStatus'],
      estimatedDeliveryDate: DateTime.tryParse(
        json['estimatedDeliveryDate']?.toString() ?? '',
      ),
      shippedAt: DateTime.tryParse(json['shippedAt']?.toString() ?? ''),
      deliveredAt: DateTime.tryParse(json['deliveredAt']?.toString() ?? ''),
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      shippingAddress: json['shippingAddress'],
    );
  }
}

class ShipmentItem {
  final int? orderItemId;
  final int? variantId;
  final String? productName;
  final String? size;
  final String? color;
  final int? quantity;
  final double? unitPrice;

  ShipmentItem({
    this.orderItemId,
    this.variantId,
    this.productName,
    this.size,
    this.color,
    this.quantity,
    this.unitPrice,
  });

  factory ShipmentItem.fromJson(Map<String, dynamic> json) {
    return ShipmentItem(
      orderItemId: json['orderItemId'],
      variantId: json['variantId'],
      productName: json['productName'],
      size: json['size'],
      color: json['color'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
    );
  }
}

class CreateShipmentRequest {
  final int orderId;
  final String carrier;
  final String trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final String? note;

  CreateShipmentRequest({
    required this.orderId,
    required this.carrier,
    required this.trackingNumber,
    this.estimatedDeliveryDate,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'note': note,
    };
  }
}

class UpdateShipmentStatusRequest {
  final String status;
  final String? note;

  UpdateShipmentStatusRequest({required this.status, this.note});

  Map<String, dynamic> toJson() {
    return {'status': status, 'note': note};
  }
}

class UpdateShipmentTrackingInfoRequest {
  final String carrier;
  final String trackingNumber;
  final DateTime? estimatedDeliveryDate;
  final String? note;

  UpdateShipmentTrackingInfoRequest({
    required this.carrier,
    required this.trackingNumber,
    this.estimatedDeliveryDate,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'carrier': carrier,
      'trackingNumber': trackingNumber,
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'note': note,
    };
  }
}
