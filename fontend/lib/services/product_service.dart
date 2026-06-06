import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/product_detail_model.dart';

class ProductService {
  static const String baseUrl = 'http://localhost:5209/api';

  Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load products');
  }

  Future<ProductDetailModel> getProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductDetailModel.fromJson(data);
    }

    throw Exception('Failed to load product detail');
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to search products');
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$categoryId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load products by category');
  }

  Future<void> createProduct({
    required String productName,
    String? description,
    required double basePrice,
    required int categoryId,
    String? brand,
    String? gender,
    String? material,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'productName': productName,
        'description': description,
        'basePrice': basePrice,
        'categoryId': categoryId,
        'brand': brand ?? 'Adidas',
        'gender': gender,
        'material': material,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<void> updateProduct({
    required int productId,
    required String productName,
    String? description,
    required double basePrice,
    required int categoryId,
    String? brand,
    String? gender,
    String? material,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/$productId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'productName': productName,
        'description': description,
        'basePrice': basePrice,
        'categoryId': categoryId,
        'brand': brand ?? 'Adidas',
        'gender': gender,
        'material': material,
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update product: ${response.body}');
    }
  }

  Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$productId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.body}');
    }
  }
}