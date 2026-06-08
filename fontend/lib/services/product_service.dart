import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product_model.dart';
import '../models/product_detail_model.dart';

class ProductService {
  String get baseUrl => AppConfig.apiBaseUrl;

  // =========================
  // PRODUCT USER API
  // =========================

  Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load products: ${response.body}');
  }

  Future<ProductDetailModel> getProductById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductDetailModel.fromJson(data);
    }

    throw Exception('Failed to load product detail: ${response.body}');
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/search?keyword=$keyword'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to search products: ${response.body}');
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/category/$categoryId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load products by category: ${response.body}');
  }

  // =========================
  // ADMIN PRODUCT CRUD
  // =========================

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

  // =========================
  // ADMIN PRODUCT VARIANT CRUD
  // =========================

  Future<List<ProductVariantModel>> getVariantsByProduct(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/variants'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductVariantModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load variants: ${response.body}');
  }

  Future<void> createVariant({
    required int productId,
    required String size,
    required String color,
    required double price,
    required int stockQuantity,
    String? sku,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/variants'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'size': size,
        'color': color,
        'price': price,
        'stockQuantity': stockQuantity,
        'sku': sku,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create variant: ${response.body}');
    }
  }

  Future<void> updateVariant({
    required int variantId,
    required String size,
    required String color,
    required double price,
    required int stockQuantity,
    String? sku,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/productvariants/$variantId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'size': size,
        'color': color,
        'price': price,
        'stockQuantity': stockQuantity,
        'sku': sku,
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update variant: ${response.body}');
    }
  }

  Future<void> deleteVariant(int variantId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/productvariants/$variantId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete variant: ${response.body}');
    }
  }

  // =========================
  // ADMIN PRODUCT IMAGE CRUD
  // =========================

  Future<List<ProductImageModel>> getImagesByProduct(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$productId/images'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductImageModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load images: ${response.body}');
  }

  Future<void> createProductImage({
    required int productId,
    required String imageUrl,
    required bool isMain,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/$productId/images'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'imageUrl': imageUrl,
        'isMain': isMain,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create product image: ${response.body}');
    }
  }

  Future<void> updateProductImage({
    required int imageId,
    required String imageUrl,
    required bool isMain,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/productimages/$imageId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'imageUrl': imageUrl,
        'isMain': isMain,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update product image: ${response.body}');
    }
  }

  Future<void> deleteProductImage(int imageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/productimages/$imageId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product image: ${response.body}');
    }
  }
}