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
}