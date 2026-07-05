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
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName']?.toString() ?? '',
      description: json['description'],
      productCount: _parseInt(json['productCount']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
