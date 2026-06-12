class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String? description;
  final int productCount;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.description,
    required this.productCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      productCount: json['productCount'] ?? 0,
    );
  }
}
