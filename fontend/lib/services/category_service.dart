import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/category_model.dart';
import 'api_client.dart';

class CategoryService {
<<<<<<< HEAD
  String get baseUrl => AppConfig.apiBaseUrl;

=======
>>>>>>> origin/develop
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/categories'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load categories: ${response.body}');
  }

  Future<void> createCategory({
    required String categoryName,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/categories'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categoryName': categoryName,
        'description': description,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create category: ${response.body}');
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String categoryName,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/categories/$categoryId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'categoryName': categoryName,
        'description': description,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update category: ${response.body}');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/categories/$categoryId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete category: ${response.body}');
    }
  }
}
