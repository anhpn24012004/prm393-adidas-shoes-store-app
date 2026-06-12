import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _changePassword() async {
    if (_currentController.text.isEmpty || _newController.text.length < 6) {
      _showMessage(context.tr('passwordLengthError'));
      return;
    }
    if (_newController.text != _confirmController.text) {
      _showMessage(context.tr('passwordMismatch'));
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      _showMessage(context.tr('passwordChanged'));
      Navigator.pop(context);
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
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('changePassword').toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            context.tr('changePasswordHeading').toUpperCase(),
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 12),
          Text(
            context.tr('passwordHint'),
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 30),
          _passwordField(_currentController, context.tr('currentPassword')),
          const SizedBox(height: 14),
          _passwordField(_newController, context.tr('newPassword')),
          const SizedBox(height: 14),
          _passwordField(
            _confirmController,
            context.tr('confirmNewPassword'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _changePassword,
            child: Text(
              (_loading
                      ? context.tr('updating')
                      : context.tr('changePassword'))
                  .toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
