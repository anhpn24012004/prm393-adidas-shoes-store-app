import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthService();
  bool _initialized = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is String) _emailController.text = argument;
    _initialized = true;
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage(context.tr('invalidEmail'));
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.forgotPassword(email);
      if (!mounted) return;
      _showMessage('${context.tr('otpSent')} $email');
      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: {'email': email},
      );
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('forgotPasswordTitle').toUpperCase()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            context.tr('checkEmail').toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('otpDescription'),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: context.tr('emailAddress'),
              prefixIcon: const Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _sendOtp,
            child: Text(
              (_loading ? context.tr('sending') : context.tr('sendOtp'))
                  .toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }
}
