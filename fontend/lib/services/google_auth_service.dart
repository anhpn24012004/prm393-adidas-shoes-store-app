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

  static const _iosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final AuthService _authService = AuthService();
  Future<void>? _initialization;

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  bool get supportsAuthenticate => _googleSignIn.supportsAuthenticate();

  Future<void> initialize() {
    final initialization = _initialization;
    if (initialization != null) {
      return initialization;
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
    final clientId = data['clientId']?.toString() ?? '';
    if (data['configured'] != true || clientId.isEmpty) {
      throw StateError(
        'Google Sign-In has not been configured on the backend.',
      );
    }

    if (kIsWeb) {
      await _googleSignIn.initialize(clientId: clientId);
      return;
    }

    await _googleSignIn.initialize(
      clientId: _iosClientId.isEmpty ? null : _iosClientId,
      serverClientId: clientId,
    );
  }

  Future<void> authenticate() async {
    await initialize();
    await _googleSignIn.authenticate();
  }

  Future<AuthSession> exchangeAccount(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google did not return an ID token.');
    }

    return _authService.googleLogin(idToken);
  }
}
