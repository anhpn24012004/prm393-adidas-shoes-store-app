import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationNotifier extends ChangeNotifier {
  NotificationNotifier._();

  static final NotificationNotifier instance = NotificationNotifier._();

  final NotificationService _service = NotificationService();

  int unreadCount = 0;
  NotificationModel? latestNotification;

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _service.getUnreadCount();
      setUnreadCount(count);
    } catch (_) {
      // Keep current count if API is unavailable.
    }
  }

  void setUnreadCount(int count) {
    if (unreadCount == count) return;
    unreadCount = count;
    notifyListeners();
  }

  void onNotificationReceived(NotificationModel notification) {
    latestNotification = notification;
    if (!notification.isRead) {
      unreadCount += 1;
    }
    notifyListeners();
  }

  void clearLatestNotification() {
    latestNotification = null;
  }
}
