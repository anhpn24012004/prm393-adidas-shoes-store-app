import 'package:flutter/material.dart';

import '../services/auth_storage.dart';

class AdminRouteGuard extends StatefulWidget {
  final WidgetBuilder builder;

  const AdminRouteGuard({
    super.key,
    required this.builder,
  });

  @override
  State<AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  late final Future<_AdminRouteState> _future = _checkAccess();
  bool _redirected = false;

  Future<_AdminRouteState> _checkAccess() async {
    final storage = AuthStorage();
    final token = await storage.getToken();
    if (token == null || token.isEmpty) {
      return _AdminRouteState.unauthenticated;
    }

    return await storage.isAdmin()
        ? _AdminRouteState.allowed
        : _AdminRouteState.forbidden;
  }

  void _redirect(String routeName) {
    if (_redirected || !mounted) return;
    _redirected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AdminRouteState>(
      future: _future,
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state == _AdminRouteState.allowed) {
          return widget.builder(context);
        }

        if (state == _AdminRouteState.unauthenticated) {
          _redirect('/login');
        } else if (state == _AdminRouteState.forbidden) {
          _redirect('/forbidden');
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

enum _AdminRouteState {
  allowed,
  unauthenticated,
  forbidden,
}
