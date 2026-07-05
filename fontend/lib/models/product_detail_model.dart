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
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final List<ProductClassificationGroupModel> classificationGroups;
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
    required this.averageRating,
    required this.reviewCount,
    required this.isActive,
    required this.classificationGroups,
    required this.images,
    required this.variants,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailModel(
      productId: _parseInt(json['productId']),
      productName: json['productName']?.toString() ?? '',
      description: json['description'],
      basePrice: _parseDouble(json['basePrice']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName']?.toString(),
      brand: json['brand']?.toString(),
      gender: json['gender']?.toString(),
      material: json['material']?.toString(),
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      classificationGroups: (json['classificationGroups'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProductClassificationGroupModel.fromJson)
          .toList(),
      images: (json['images'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProductImageModel.fromJson)
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProductVariantModel.fromJson)
          .toList(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ProductClassificationGroupModel {
  final String name;
  final int sortOrder;
  final List<ProductClassificationOptionModel> options;

  const ProductClassificationGroupModel({
    required this.name,
    required this.sortOrder,
    required this.options,
  });

  factory ProductClassificationGroupModel.fromJson(Map<String, dynamic> json) {
    return ProductClassificationGroupModel(
      name: json['name']?.toString() ?? '',
      sortOrder: ProductDetailModel._parseInt(json['sortOrder']),
      options: (json['options'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ProductClassificationOptionModel.fromJson)
          .toList(),
    );
  }
}

class ProductClassificationOptionModel {
  final String name;
  final String? description;
  final String? imageUrl;
  final int sortOrder;

  const ProductClassificationOptionModel({
    required this.name,
    this.description,
    this.imageUrl,
    required this.sortOrder,
  });

  factory ProductClassificationOptionModel.fromJson(Map<String, dynamic> json) {
    return ProductClassificationOptionModel(
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      sortOrder: ProductDetailModel._parseInt(json['sortOrder']),
    );
  }
}

class ProductClassificationEditorData {
  final List<ProductClassificationGroupModel> classificationGroups;
  final List<ProductVariantModel> variants;

  const ProductClassificationEditorData({
    required this.classificationGroups,
    required this.variants,
  });

  factory ProductClassificationEditorData.fromJson(Map<String, dynamic> json) {
    return ProductClassificationEditorData(
      classificationGroups: (json['classificationGroups'] as List? ?? [])
          .map((item) => ProductClassificationGroupModel.fromJson(item))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((item) => ProductVariantModel.fromJson(item))
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
      imageId: ProductDetailModel._parseInt(json['imageId']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      isMain: json['isMain'] ?? false,
    );
  }
}

class ProductVariantModel {
  final int variantId;
  final String size;
  final String color;
  final String? imageUrl;
  final List<String> optionValues;
  final double price;
  final int stockQuantity;
  final String? sku;
  final bool isActive;

  ProductVariantModel({
    required this.variantId,
    required this.size,
    required this.color,
    this.imageUrl,
    required this.optionValues,
    required this.price,
    required this.stockQuantity,
    this.sku,
    required this.isActive,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      variantId: ProductDetailModel._parseInt(json['variantId']),
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      optionValues: (json['optionValues'] as List? ?? [])
          .map((value) => value.toString())
          .toList(),
      price: ProductDetailModel._parseDouble(json['price']),
      stockQuantity: ProductDetailModel._parseInt(json['stockQuantity']),
      sku: json['sku']?.toString(),
      isActive: json['isActive'] ?? false,
    );
  }
}
