import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ghn_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class GhnService {
  final AuthStorage _authStorage = AuthStorage();

  Future<List<GhnProvince>> getProvinces() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/ghn/provinces'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => GhnProvince.fromJson(item)).toList();
    }

    throw Exception(_errorMessage(response));
  }

  Future<List<GhnDistrict>> getDistricts(int provinceId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiClient.baseUrl}/ghn/districts',
      ).replace(queryParameters: {'provinceId': provinceId.toString()}),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => GhnDistrict.fromJson(item)).toList();
    }

    throw Exception(_errorMessage(response));
  }

  Future<List<GhnWard>> getWards(int districtId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiClient.baseUrl}/ghn/wards',
      ).replace(queryParameters: {'districtId': districtId.toString()}),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => GhnWard.fromJson(item)).toList();
    }

    throw Exception(_errorMessage(response));
  }

  Future<GhnShippingFee> calculateFee({
    required int toDistrictId,
    required String toWardCode,
    required List<int> quantities,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/ghn/calculate-fee'),
      headers: await _headers(),
      body: jsonEncode({
        'toDistrictId': toDistrictId,
        'toWardCode': toWardCode,
        'items': quantities.map((quantity) => {'quantity': quantity}).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return GhnShippingFee.fromJson(jsonDecode(response.body));
    }

    throw Exception(_errorMessage(response));
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authStorage.getToken();

    if (token == null) {
      throw Exception('Login required');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _errorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      final message = data['message'];

      if (message != null) {
        return message.toString();
      }
    } catch (_) {
      // Fall through.
    }

    return 'Không tính được phí vận chuyển, vui lòng chọn lại địa chỉ.';
  }
}
