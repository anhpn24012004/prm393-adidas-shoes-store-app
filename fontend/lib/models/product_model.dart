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
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final int imageCount;
  final int activeVariantCount;
  final int totalStock;

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
    required this.averageRating,
    required this.reviewCount,
    required this.isActive,
    required this.imageCount,
    required this.activeVariantCount,
    required this.totalStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: _parseInt(json['productId']),
      productName: json['productName'] ?? '',
      description: json['description'],
      basePrice: _parseDouble(json['basePrice']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'],
      brand: json['brand'],
      gender: json['gender'],
      material: json['material'],
      mainImageUrl: json['mainImageUrl'],
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: _parseInt(json['reviewCount']),
      isActive: json['isActive'] ?? false,
      imageCount: _parseInt(json['imageCount']),
      activeVariantCount: _parseInt(json['activeVariantCount']),
      totalStock: _parseInt(json['totalStock']),
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

class ProductRouteArgs {
  final ProductModel product;
  final bool fromCreateFlow;

  const ProductRouteArgs({required this.product, this.fromCreateFlow = false});
}

class PagedProductResponse {
  final List<ProductModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PagedProductResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PagedProductResponse.fromJson(Map<String, dynamic> json) {
    final items = json['items'] as List? ?? [];

    return PagedProductResponse(
      items: items
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList(),
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 8,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      hasNextPage: json['hasNextPage'] ?? false,
    );
  }
}
