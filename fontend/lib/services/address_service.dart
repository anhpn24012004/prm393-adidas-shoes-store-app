import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/address_model.dart';
import 'api_client.dart';
import 'auth_storage.dart';

class AddressService {
  final AuthStorage _storage = AuthStorage();

  Future<List<UserAddress>> getAddresses() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/addresses'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data
          .map((item) => UserAddress.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(_message(response));
  }

  Future<UserAddress> createAddress(SaveAddressRequest request) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/addresses'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      return UserAddress.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<UserAddress> updateAddress(
    int addressId,
    SaveAddressRequest request,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/addresses/$addressId'),
      headers: await _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return UserAddress.fromJson(jsonDecode(response.body));
    }

    throw Exception(_message(response));
  }

  Future<void> setDefault(int addressId) async {
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/addresses/$addressId/default'),
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }
  }

  Future<void> deleteAddress(int addressId) async {
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/addresses/$addressId'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception(_message(response));
    }
  }

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    if (token == null) throw Exception('Login required');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String _message(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['message'] != null) return body['message'].toString();
      if (body['errors'] != null) return 'Please check the address details.';
    } catch (_) {
      // Fall through to the status message.
    }
    return 'Request failed (${response.statusCode})';
  }
}
