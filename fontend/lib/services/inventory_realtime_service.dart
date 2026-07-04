import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';

import '../config/app_config.dart';
import '../models/stock_changed_event.dart';

class InventoryRealtimeService {
  InventoryRealtimeService._();

  static final InventoryRealtimeService instance = InventoryRealtimeService._();

  final StreamController<StockChangedEvent> _stockChangedController =
      StreamController<StockChangedEvent>.broadcast();

  HubConnection? _connection;
  bool _connecting = false;

  Stream<StockChangedEvent> get stockChangedStream =>
      _stockChangedController.stream;

  Future<void> initialize() async {
    await connectRealtime();
  }

  Future<void> connectRealtime() async {
    if (_connecting || _connection != null) return;

    _connecting = true;
    try {
      final connection = HubConnectionBuilder()
          .withUrl('${AppConfig.signalRBaseUrl}/hubs/inventory')
          .withAutomaticReconnect()
          .build();

      connection.on('StockChanged', (arguments) {
        final payload = arguments?.firstOrNull;
        if (payload is! Map) return;

        final event = StockChangedEvent.fromJson(
          Map<String, dynamic>.from(payload),
        );
        _stockChangedController.add(event);
      });

      connection.onclose(({error}) {
        _connection = null;
      });

      await connection.start();
      _connection = connection;
    } catch (_) {
      // Stock realtime is optional; screens can still refresh through APIs.
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
}

extension _FirstOrNull<E> on List<E>? {
  E? get firstOrNull => this == null || this!.isEmpty ? null : this!.first;
}
