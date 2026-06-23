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
      productId: json['productId'],
      productName: json['productName'] ?? '',
      description: json['description'],
      basePrice: (json['basePrice'] as num).toDouble(),
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      brand: json['brand'],
      gender: json['gender'],
      material: json['material'],
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? false,
      classificationGroups: (json['classificationGroups'] as List? ?? [])
          .map((e) => ProductClassificationGroupModel.fromJson(e))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => ProductImageModel.fromJson(e))
          .toList(),
      variants: (json['variants'] as List? ?? [])
          .map((e) => ProductVariantModel.fromJson(e))
          .toList(),
    );
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
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      options: (json['options'] as List? ?? [])
          .map((item) => ProductClassificationOptionModel.fromJson(item))
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
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      sortOrder: json['sortOrder'] ?? 0,
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
      variantId: json['variantId'],
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      imageUrl: json['imageUrl'],
      optionValues: (json['optionValues'] as List? ?? [])
          .map((value) => value.toString())
          .toList(),
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'],
      isActive: json['isActive'] ?? false,
    );
  }
}
