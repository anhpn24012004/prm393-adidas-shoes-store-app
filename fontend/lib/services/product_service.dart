import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/product_model.dart';
import '../models/product_detail_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class ProductService {
  final _authStorage = AuthStorage();

  String get baseUrl => AppConfig.apiBaseUrl;

  // =========================
  // PRODUCT USER API
  // =========================

  Future<PagedProductResponse> getProducts({
    int pageNumber = 1,
    int pageSize = 8,
    String? keyword,
    int? categoryId,
  }) async {
    final queryParameters = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
      if (categoryId != null) 'categoryId': categoryId.toString(),
    };

    final uri = Uri.parse(
      '${ApiClient.baseUrl}/products',
    ).replace(queryParameters: queryParameters);

    debugPrint('GET products: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return _parseProductsResponse(decoded);
    }

    throw Exception('Failed to load products: ${response.body}');
  }

  PagedProductResponse _parseProductsResponse(Object? decoded) {
    if (decoded is Map<String, dynamic>) {
      return PagedProductResponse.fromJson(decoded);
    }

    if (decoded is List) {
      final products = decoded
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PagedProductResponse(
        items: products,
        pageNumber: 1,
        pageSize: products.length,
        totalItems: products.length,
        totalPages: 1,
        hasPreviousPage: false,
        hasNextPage: false,
      );
    }

    throw Exception('Invalid products response format');
  }

  Future<List<ProductModel>> getProductList({
    int pageNumber = 1,
    int pageSize = 50,
    String? keyword,
    int? categoryId,
  }) async {
    final result = await getProducts(
      pageNumber: pageNumber,
      pageSize: pageSize,
      keyword: keyword,
      categoryId: categoryId,
    );

    return result.items;
  }

  Future<PagedProductResponse> getAdminProducts({
    int pageNumber = 1,
    int pageSize = 10,
    String? keyword,
    int? categoryId,
    bool? isActive,
  }) async {
    final queryParameters = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (keyword != null && keyword.trim().isNotEmpty) 'keyword': keyword,
      if (categoryId != null) 'categoryId': categoryId.toString(),
      if (isActive != null) 'isActive': isActive.toString(),
    };

    final uri = Uri.parse(
      '${ApiClient.baseUrl}/products/admin',
    ).replace(queryParameters: queryParameters);

    debugPrint('GET admin products: $uri');

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return _parseProductsResponse(decoded);
    }

    throw Exception(
      'Failed to load admin products (${response.statusCode}): ${response.body}',
    );
  }

  Future<ProductDetailModel> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/products/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductDetailModel.fromJson(data);
    }

    throw Exception('Failed to load product detail: ${response.body}');
  }

  Future<List<ProductModel>> searchProducts(String keyword) async {
    return getProductList(keyword: keyword);
  }

  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    return getProductList(categoryId: categoryId);
  }

  // =========================
  // ADMIN PRODUCT CRUD
  // =========================

  Future<int> createProduct({
    required String productName,
    String? description,
    required double basePrice,
    required int categoryId,
    String? brand,
    String? gender,
    String? material,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/products'),
      headers: await _headers(),
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
      throw Exception(_message(response, 'Failed to create product'));
    }

    final data = jsonDecode(response.body);
    final productId = data is Map<String, dynamic>
        ? data['productId'] as int?
        : null;
    if (productId == null || productId <= 0) {
      throw Exception('Create product response did not include productId');
    }

    return productId;
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
      Uri.parse('${ApiClient.baseUrl}/products/$productId'),
      headers: await _headers(),
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
      throw Exception(_message(response, 'Failed to update product'));
    }
  }

  Future<void> publishProduct(int productId) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/publish'),
      headers: await _headers(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to publish product'));
    }
  }

  Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/products/$productId'),
      headers: await _headers(includeContentType: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to delete product'));
    }
  }

  // =========================
  // ADMIN PRODUCT VARIANT CRUD
  // =========================

  Future<List<ProductVariantModel>> getVariantsByProduct(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/variants'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductVariantModel.fromJson(item)).toList();
    }

    throw Exception(_message(response, 'Failed to load variants'));
  }

  Future<ProductClassificationEditorData> getProductClassifications(
    int productId,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/classifications'),
      headers: await _headers(includeContentType: false),
    );

    if (response.statusCode == 200) {
      return ProductClassificationEditorData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(_message(response, 'Failed to load classifications'));
  }

  Future<void> syncProductClassifications({
    required int productId,
    required List<Map<String, dynamic>> classificationGroups,
    required List<Map<String, dynamic>> variants,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/classifications'),
      headers: await _headers(),
      body: jsonEncode({
        'classificationGroups': classificationGroups,
        'variants': variants,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to save classifications'));
    }
  }

  Future<void> createVariant({
    required int productId,
    required String size,
    required String color,
    String? imageUrl,
    required double price,
    required int stockQuantity,
    String? sku,
    bool isActive = true,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/variants'),
      headers: await _headers(),
      body: jsonEncode({
        'size': size,
        'color': color,
        'imageUrl': imageUrl,
        'price': price,
        'stockQuantity': stockQuantity,
        'sku': sku,
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_message(response, 'Failed to create variant'));
    }
  }

  Future<void> updateVariant({
    required int variantId,
    required String size,
    required String color,
    String? imageUrl,
    required double price,
    required int stockQuantity,
    String? sku,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/productvariants/$variantId'),
      headers: await _headers(),
      body: jsonEncode({
        'size': size,
        'color': color,
        'imageUrl': imageUrl,
        'price': price,
        'stockQuantity': stockQuantity,
        'sku': sku,
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to update variant'));
    }
  }

  Future<void> deleteVariant(int variantId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/productvariants/$variantId'),
      headers: await _headers(includeContentType: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to delete variant'));
    }
  }

  // =========================
  // ADMIN PRODUCT IMAGE CRUD
  // =========================

  Future<List<ProductImageModel>> getImagesByProduct(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/images'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => ProductImageModel.fromJson(item)).toList();
    }

    throw Exception(_message(response, 'Failed to load images'));
  }

  Future<void> createProductImage({
    required int productId,
    required String imageUrl,
    required bool isMain,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/products/$productId/images'),
      headers: await _headers(),
      body: jsonEncode({'imageUrl': imageUrl, 'isMain': isMain}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_message(response, 'Failed to create product image'));
    }
  }

  Future<ProductImageModel> uploadProductImage({
    required int productId,
    required List<int> bytes,
    required String fileName,
    required bool isMain,
  }) async {
    final uri = Uri.parse(
      '${ApiClient.baseUrl}/products/$productId/images/upload',
    );
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _headers(includeContentType: false));
    request.fields['isMain'] = isMain.toString();
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return ProductImageModel.fromJson(decoded as Map<String, dynamic>);
    }

    throw Exception(_message(response, 'Failed to upload product image'));
  }

  Future<void> updateProductImage({
    required int imageId,
    required String imageUrl,
    required bool isMain,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/productimages/$imageId'),
      headers: await _headers(),
      body: jsonEncode({'imageUrl': imageUrl, 'isMain': isMain}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to update product image'));
    }
  }

  Future<void> deleteProductImage(int imageId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/productimages/$imageId'),
      headers: await _headers(includeContentType: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_message(response, 'Failed to delete product image'));
    }
  }

  Future<Map<String, String>> _headers({bool includeContentType = true}) async {
    final token = await _authStorage.getToken();
    if (token == null) {
      throw Exception('Admin login required');
    }

    return {
      if (includeContentType) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _message(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}

    return '$fallback (${response.statusCode})';
  }
}
