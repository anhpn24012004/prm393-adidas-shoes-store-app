import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../localization/app_localization.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../product/product_detail_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  late Future<List<CategoryModel>> _categoriesFuture;

  int? selectedCategoryId;
  String selectedCategoryName = 'All';

  Future<List<ProductModel>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getCategories();
  }

  String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  void _loadProductsByCategory(CategoryModel category) {
    setState(() {
      selectedCategoryId = category.categoryId;
      selectedCategoryName = category.categoryName;
      _productsFuture = _productService.getProductsByCategory(
        category.categoryId,
      );
    });
  }

  void _goToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.productId),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image),
      );
    }

    return Image.network(
      imageUrl,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return FutureBuilder<List<CategoryModel>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${context.tr('error')}: ${snapshot.error}'),
            ),
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Center(child: Text(context.tr('noCategories')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategoryId == category.categoryId;

            return Card(
              color: isSelected ? Colors.black : null,
              child: ListTile(
                title: Text(
                  category.categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  category.description ?? context.tr('noDescription'),
                  style: TextStyle(
                    color: isSelected ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
                trailing: Text(
                  '${category.productCount}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => _loadProductsByCategory(category),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsByCategory() {
    if (_productsFuture == null) {
      return Center(child: Text(context.tr('selectCategory')));
    }

    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${context.tr('error')}: ${snapshot.error}'),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Text('${context.tr('noProductsIn')} $selectedCategoryName'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return Card(
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildProductImage(product.mainImageUrl),
                ),
                title: Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${formatPrice(product.basePrice)}\n${product.categoryName ?? ''}',
                ),
                isThreeLine: true,
                onTap: () => _goToDetail(product),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('categories').toUpperCase())),
      body: isWideScreen
          ? Row(
              children: [
                SizedBox(width: 320, child: _buildCategoryList()),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          selectedCategoryName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: _buildProductsByCategory()),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                SizedBox(height: 260, child: _buildCategoryList()),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      selectedCategoryName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildProductsByCategory()),
              ],
            ),
    );
  }
}
