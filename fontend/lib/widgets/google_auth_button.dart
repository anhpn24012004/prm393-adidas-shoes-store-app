import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    } catch (error, stackTrace) {
      debugPrint('Google init error: $error');
      debugPrint('Google init stackTrace: $stackTrace');
      _setupError = _message(error);
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  Future<void> _authenticate() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final session = await _googleAuth.signIn();
      widget.onAuthenticated(session);
    } catch (error, stackTrace) {
      debugPrint('Google sign-in error: $error');
      debugPrint('Google sign-in stackTrace: $stackTrace');

      widget.onError(_message(error));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _message(Object error) {
    if (error is PlatformException) {
      return 'Google PlatformException: code=${error.code}, message=${error.message}, details=${error.details}';
    }

    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '');
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
        onPressed: _authenticate,
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