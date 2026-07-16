class GhnProvince {
  final int provinceId;
  final String provinceName;

  const GhnProvince({required this.provinceId, required this.provinceName});

  factory GhnProvince.fromJson(Map<String, dynamic> json) {
    return GhnProvince(
      provinceId: json['provinceId'] ?? json['ProvinceID'] ?? 0,
      provinceName: json['provinceName'] ?? json['ProvinceName'] ?? '',
    );
  }
}

class GhnDistrict {
  final int districtId;
  final int provinceId;
  final String districtName;

  const GhnDistrict({
    required this.districtId,
    required this.provinceId,
    required this.districtName,
  });

  factory GhnDistrict.fromJson(Map<String, dynamic> json) {
    return GhnDistrict(
      districtId: json['districtId'] ?? json['DistrictID'] ?? 0,
      provinceId: json['provinceId'] ?? json['ProvinceID'] ?? 0,
      districtName: json['districtName'] ?? json['DistrictName'] ?? '',
    );
  }
}

class GhnWard {
  final String wardCode;
  final int districtId;
  final String wardName;

  const GhnWard({
    required this.wardCode,
    required this.districtId,
    required this.wardName,
  });

  factory GhnWard.fromJson(Map<String, dynamic> json) {
    return GhnWard(
      wardCode:
          json['wardCode']?.toString() ?? json['WardCode']?.toString() ?? '',
      districtId: json['districtId'] ?? json['DistrictID'] ?? 0,
      wardName: json['wardName'] ?? json['WardName'] ?? '',
    );
  }
}

class GhnShippingFee {
  final double shippingFee;
  final double serviceFee;
  final double insuranceFee;
  final DateTime? expectedDeliveryTime;

  const GhnShippingFee({
    required this.shippingFee,
    required this.serviceFee,
    required this.insuranceFee,
    this.expectedDeliveryTime,
  });

  factory GhnShippingFee.fromJson(Map<String, dynamic> json) {
    return GhnShippingFee(
      shippingFee: (json['shippingFee'] as num? ?? 0).toDouble(),
      serviceFee: (json['serviceFee'] as num? ?? 0).toDouble(),
      insuranceFee: (json['insuranceFee'] as num? ?? 0).toDouble(),
      expectedDeliveryTime: DateTime.tryParse(
        json['expectedDeliveryTime']?.toString() ?? '',
      ),
    );
  }
}
