import 'package:flutter/material.dart';

import '../../models/notification_model.dart';
import '../../providers/notification_notifier.dart';
import '../../services/auth_storage.dart';
import '../../services/notification_service.dart';
import '../product/product_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  late Future<List<NotificationModel>> _future;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _reload();
  }

  Future<void> _loadRole() async {
    final isAdmin = await AuthStorage().isAdmin();
    if (mounted) {
      setState(() => _isAdmin = isAdmin);
    }
  }

  void _reload() {
    _future = _service.getMyNotifications();
  }

  Future<void> _markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      await NotificationNotifier.instance.refreshUnreadCount();
      if (mounted) setState(_reload);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _openNotification(NotificationModel item) async {
    if (!item.isRead) {
      try {
        await _service.markAsRead(item.notificationId);
        await NotificationNotifier.instance.refreshUnreadCount();
      } catch (_) {}
    }

    if (!mounted) return;

    if (item.relatedOrderId != null) {
      Navigator.pushNamed(
        context,
        _isAdmin ? '/admin/orders' : '/order-detail',
        arguments: item.relatedOrderId,
      );
      return;
    }

    if (item.relatedProductId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailScreen(productId: item.relatedProductId!),
        ),
      );
      return;
    }

    if (item.relatedRefundRequestId != null) {
      Navigator.pushNamed(
        context,
        _isAdmin ? '/admin/refund-requests' : '/refund-status',
      );
      return;
    }

    if (item.relatedReturnRequestId != null) {
      Navigator.pushNamed(
        context,
        _isAdmin ? '/admin/returns-refunds' : '/refund-status',
      );
      return;
    }

    if (item.actionUrl != null && item.actionUrl!.startsWith('/')) {
      Navigator.pushNamed(context, item.actionUrl!);
    }
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  String _formatCreatedAt(DateTime? value) {
    if (value == null) return '';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} '
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('MARK ALL READ'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_reload);
          await _future;
        },
        child: FutureBuilder<List<NotificationModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(snapshot.error.toString()),
                  ),
                ],
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No notifications yet')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: item.isRead ? Colors.white : const Color(0xFFF3F8FF),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _openNotification(item),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: item.isRead
                                        ? Colors.black87
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.type,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(item.message),
                          const SizedBox(height: 8),
                          Text(
                            _formatCreatedAt(item.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
