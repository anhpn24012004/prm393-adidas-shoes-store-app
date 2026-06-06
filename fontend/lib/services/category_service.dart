import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = 'http://localhost:5209/api';

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => CategoryModel.fromJson(item)).toList();
    }

    throw Exception('Failed to load categories');
  }
}