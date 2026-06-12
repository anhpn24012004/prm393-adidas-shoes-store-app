class UserAddress {
  final int addressId;
  final String receiverName;
  final String phone;
  final String addressLine;
  final String? ward;
  final String? district;
  final String? city;
  final bool isDefault;

  const UserAddress({
    required this.addressId,
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.ward,
    this.district,
    this.city,
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
      isDefault: json['isDefault'] == true,
    );
  }

  String get formattedAddress {
    return [addressLine, ward, district, city]
        .where((part) => part != null && part!.trim().isNotEmpty)
        .join(', ');
  }
}

class SaveAddressRequest {
  final String receiverName;
  final String phone;
  final String addressLine;
  final String? ward;
  final String? district;
  final String? city;
  final bool isDefault;

  const SaveAddressRequest({
    required this.receiverName,
    required this.phone,
    required this.addressLine,
    this.ward,
    this.district,
    this.city,
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
      'isDefault': isDefault,
    };
  }
}
