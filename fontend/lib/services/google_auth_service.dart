import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../models/auth_model.dart';
import 'api_client.dart';
import 'auth_service.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final instance = GoogleAuthService._();

  static const _productionWebClientId =
      '460139502851-fkhhmn6sie91ms831lenmf3o31ju5u7k.apps.googleusercontent.com';
  static const _androidClientId =
      '460139502851-hbv6pbmrbp9gdek6u4g3sje82ee78qcq.apps.googleusercontent.com';

  final AuthService _authService = AuthService();

  GoogleSignIn? _googleSignIn;
  Future<void>? _initialization;

  Future<void> initialize() {
    final existing = _initialization;
    if (existing != null) {
      return existing;
    }

    final pending = _initialize();
    _initialization = pending;

    return pending.catchError((Object error) {
      _initialization = null;
      throw error;
    });
  }

  Future<void> _initialize() async {
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/auth/google-config'),
    );

    if (response.statusCode != 200) {
      throw StateError(
        'Unable to load Google Sign-In configuration from the backend.',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final webClientId = _resolveWebClientId(data);

    if (data['configured'] != true || webClientId.isEmpty) {
      throw StateError(
        'Google Sign-In has not been configured on the backend.',
      );
    }

    _googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: kIsWeb ? webClientId : null,
      serverClientId: kIsWeb ? null : webClientId,
    );
  }

  String _resolveWebClientId(Map<String, dynamic> data) {
    final clientId = data['clientId']?.toString().trim() ?? '';

    if (clientId == _androidClientId) {
      throw StateError(
        'Backend returned the Android OAuth client ID. Android Google Sign-In '
        'must use the Web Client ID as serverClientId.',
      );
    }

    if (clientId.isNotEmpty && clientId != _productionWebClientId) {
      throw StateError(
        'Backend returned an unexpected Google OAuth client ID.',
      );
    }

    return clientId;
  }

  Future<AuthSession> signIn() async {
    await initialize();

    final googleSignIn = _googleSignIn;
    if (googleSignIn == null) {
      throw StateError('Google Sign-In has not been initialized.');
    }

    final account = await googleSignIn.signIn();

    if (account == null) {
      throw StateError('Google sign-in was canceled.');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token.');
    }

    return _authService.googleLogin(idToken);
  }

  Future<void> signOut() async {
    await _googleSignIn?.signOut();
  }
}
