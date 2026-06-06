class ProductDetailModel {
  final int productId;
  final String productName;
  final String? description;
  final double basePrice;
  final int categoryId;
  final String? categoryName;
  final String? brand;
  final String? gender;
  final String? material;
  final bool isActive;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  ProductDetailModel({
    required this.productId,
    required this.productName,
    this.description,
    required this.basePrice,
    required this.categoryId,
    this.categoryName,
    this.brand,
    this.gender,
    this.material,
    required this.isActive,
    required this.images,
    required this.variants,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      description: json['description'],
      basePrice: (json['basePrice'] as num).toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      brand: json['brand'],
      gender: json['gender'],
      material: json['material'],
      isActive: json['isActive'] ?? false,
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImageModel.fromJson(e))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariantModel.fromJson(e))
          .toList(),
    );
  }
}

class ProductImageModel {
  final int imageId;
  final String imageUrl;
  final bool isMain;

  ProductImageModel({
    required this.imageId,
    required this.imageUrl,
    required this.isMain,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imageId: json['imageId'],
      imageUrl: json['imageUrl'] ?? '',
      isMain: json['isMain'] ?? false,
    );
  }
}

class ProductVariantModel {
  final int variantId;
  final String size;
  final String color;
  final double price;
  final int stockQuantity;
  final String? sku;
  final bool isActive;

  ProductVariantModel({
    required this.variantId,
    required this.size,
    required this.color,
    required this.price,
    required this.stockQuantity,
    this.sku,
    required this.isActive,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      variantId: json['variantId'],
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'],
      isActive: json['isActive'] ?? false,
    );
  }
}