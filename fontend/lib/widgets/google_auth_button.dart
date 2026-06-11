import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_model.dart';
import '../services/google_auth_service.dart';
import 'google_button_stub.dart'
    if (dart.library.html) 'google_button_web.dart';

class GoogleAuthButton extends StatefulWidget {
  final String label;
  final ValueChanged<AuthSession> onAuthenticated;
  final ValueChanged<String> onError;

  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onAuthenticated,
    required this.onError,
  });

  @override
  State<GoogleAuthButton> createState() => _GoogleAuthButtonState();
}

class _GoogleAuthButtonState extends State<GoogleAuthButton> {
  final _googleAuth = GoogleAuthService.instance;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  bool _initializing = true;
  bool _loading = false;
  String? _setupError;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _googleAuth.initialize();
      _subscription = _googleAuth.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: (Object error) => widget.onError(_message(error)),
      );
    } catch (error) {
      _setupError = _message(error);
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;

    setState(() => _loading = true);
    try {
      final session = await _googleAuth.exchangeAccount(event.user);
      widget.onAuthenticated(session);
    } catch (error) {
      widget.onError(_message(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _authenticate() async {
    setState(() => _loading = true);
    try {
      await _googleAuth.authenticate();
    } catch (error) {
      widget.onError(_message(error));
      if (mounted) setState(() => _loading = false);
    }
  }

  String _message(Object error) {
    if (error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled) {
      return 'Google sign-in was canceled.';
    }

    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing || _loading) {
      return const SizedBox(
        height: 44,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_setupError != null) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => widget.onError(_setupError!),
          icon: const Text(
            'G',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4285F4),
            ),
          ),
          label: Text(widget.label.toUpperCase()),
        ),
      );
    }

    if (kIsWeb) {
      return Center(child: buildGoogleSdkButton());
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _googleAuth.supportsAuthenticate ? _authenticate : null,
        icon: const Text(
          'G',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4285F4),
          ),
        ),
        label: Text(widget.label.toUpperCase()),
      ),
    );
  }
}
