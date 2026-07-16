import 'package:signalr_netcore/signalr_client.dart';

import '../models/notification_model.dart';
import '../providers/notification_notifier.dart';
import '../config/app_config.dart';
import '../services/auth_storage.dart';

class NotificationRealtimeService {
  NotificationRealtimeService._();

  static final NotificationRealtimeService instance =
      NotificationRealtimeService._();

  final AuthStorage _authStorage = AuthStorage();
  HubConnection? _connection;
  bool _connecting = false;

  Future<void> initialize() async {
    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      await disconnect();
      return;
    }

    await NotificationNotifier.instance.refreshUnreadCount();
    await connectRealtime();
  }

  Future<void> connectRealtime() async {
    if (_connecting) return;

    final token = await _authStorage.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    _connecting = true;
    try {
      await disconnect();

      final connection = HubConnectionBuilder()
          .withUrl(
            '${AppConfig.signalRBaseUrl}/hubs/notifications',
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token,
            ),
          )
          .withAutomaticReconnect()
          .build();

      connection.on('NotificationReceived', (arguments) {
        final payload = arguments?.firstOrNull;
        if (payload is! Map) return;

        final notification = NotificationModel.fromJson(
          Map<String, dynamic>.from(payload),
        );
        NotificationNotifier.instance.onNotificationReceived(notification);
      });

      connection.on('UnreadCountChanged', (arguments) {
        final payload = arguments?.firstOrNull;
        if (payload is! Map) return;

        final count = payload['count'];
        if (count is int) {
          NotificationNotifier.instance.setUnreadCount(count);
        }
      });

      connection.onclose(({error}) {
        _connection = null;
      });

      await connection.start();
      _connection = connection;
    } catch (_) {
      // Realtime is optional; API polling still works for unread count.
    } finally {
      _connecting = false;
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {}
    }
  }

  Future<void> reconnectAfterLogin() async {
    await initialize();
  }

  Future<void> disconnectAfterLogout() async {
    await disconnect();
    NotificationNotifier.instance.setUnreadCount(0);
    NotificationNotifier.instance.clearLatestNotification();
  }
}

extension _FirstOrNull<E> on List<E>? {
  E? get firstOrNull => this == null || this!.isEmpty ? null : this!.first;
}
