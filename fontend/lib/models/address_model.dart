class UserAddress {
  final int addressId;
  final String receiverName;
  final String phone;
  final String addressLine;
  final String? ward;
  final String? district;
  final String? city;
  final int? provinceId;
  final int? districtId;
  final String? wardCode;
  final bool isDefault;

  const UserAddress({
    required this.addressId,
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.ward,
    this.district,
    this.city,
    this.provinceId,
    this.districtId,
    this.wardCode,
    required this.isDefault,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      addressId: json['addressId'] ?? 0,
      receiverName: json['receiverName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine: json['addressLine'] ?? '',
      ward: json['ward'],
      district: json['district'],
      city: json['city'],
      provinceId: (json['provinceId'] as num?)?.toInt(),
      districtId: (json['districtId'] as num?)?.toInt(),
      wardCode: json['wardCode']?.toString(),
      isDefault: json['isDefault'] == true,
    );
  }

  String get formattedAddress {
    return [
      addressLine,
      ward,
      district,
      city,
    ].where((part) => part?.trim().isNotEmpty == true).join(', ');
  }
}

class SaveAddressRequest {
  final String receiverName;
  final String phone;
  final String addressLine;
  final String? ward;
  final String? district;
  final String? city;
  final int? provinceId;
  final int? districtId;
  final String? wardCode;
  final bool isDefault;

  const SaveAddressRequest({
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.ward,
    this.district,
    this.city,
    this.provinceId,
    this.districtId,
    this.wardCode,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverName': receiverName,
      'phone': phone,
      'addressLine': addressLine,
      'ward': ward,
      'district': district,
      'city': city,
      'provinceId': provinceId,
      'districtId': districtId,
      'wardCode': wardCode,
      'isDefault': isDefault,
    };
  }
}
