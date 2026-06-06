class ProductModel {
  final int productId;
  final String productName;
  final String? description;
  final double basePrice;
  final int categoryId;
  final String? categoryName;
  final String? brand;
  final String? gender;
  final String? material;
  final String? mainImageUrl;
  final bool isActive;

  ProductModel({
    required this.productId,
    required this.productName,
    this.description,
    required this.basePrice,
    required this.categoryId,
    this.categoryName,
    this.brand,
    this.gender,
    this.material,
    this.mainImageUrl,
    required this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      description: json['description'],
      basePrice: (json['basePrice'] as num).toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      brand: json['brand'],
      gender: json['gender'],
      material: json['material'],
      mainImageUrl: json['mainImageUrl'],
      isActive: json['isActive'] ?? false,
    );
  }
}