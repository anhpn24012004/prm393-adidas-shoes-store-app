import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/notification_model.dart';
import '../providers/notification_notifier.dart';
import '../services/auth_storage.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  NotificationModel? _lastShown;

  Future<void> _openNotifications() async {
    final authStorage = AuthStorage();
    final token = await authStorage.getToken();
    final userId = await authStorage.getUserId();

    if (!mounted) return;

    if (token == null || userId == null || userId <= 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    AppConfig.currentUserId = userId;
    await Navigator.pushNamed(context, '/notifications');
    if (mounted) {
      await NotificationNotifier.instance.refreshUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationNotifier.instance,
      builder: (context, _) {
        final notifier = NotificationNotifier.instance;
        final latest = notifier.latestNotification;

        if (latest != null && latest != _lastShown) {
          _lastShown = latest;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${latest.title}: ${latest.message}'),
                duration: const Duration(seconds: 4),
              ),
            );
            notifier.clearLatestNotification();
          });
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: _openNotifications,
              icon: const Icon(Icons.notifications_none_outlined),
            ),
            if (notifier.unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    notifier.unreadCount > 99
                        ? '99+'
                        : '${notifier.unreadCount}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
