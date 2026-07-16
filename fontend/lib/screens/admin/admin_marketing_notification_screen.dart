import 'package:flutter/material.dart';

import '../../services/notification_service.dart';

class AdminMarketingNotificationScreen extends StatefulWidget {
  const AdminMarketingNotificationScreen({super.key});

  @override
  State<AdminMarketingNotificationScreen> createState() =>
      _AdminMarketingNotificationScreenState();
}

class _AdminMarketingNotificationScreenState
    extends State<AdminMarketingNotificationScreen> {
  final _service = NotificationService();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _productIdController = TextEditingController();
  final _actionUrlController = TextEditingController();
  String _type = 'Deal';
  String _targetRole = 'Customer';
  bool _submitting = false;

  static const _types = ['Deal', 'Discount', 'FlashSale', 'Voucher'];
  static const _targetRoles = ['Customer', 'Admin'];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _productIdController.dispose();
    _actionUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final relatedProductIdText = _productIdController.text.trim();
    final relatedProductId = relatedProductIdText.isEmpty
        ? null
        : int.tryParse(relatedProductIdText);

    if (title.isEmpty || message.isEmpty) {
      _show('Title and message are required.');
      return;
    }

    if (relatedProductIdText.isNotEmpty && relatedProductId == null) {
      _show('Related product ID must be a number.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await _service.broadcastMarketingNotification(
        title: title,
        message: message,
        type: _type,
        targetRole: _targetRole,
        relatedProductId: relatedProductId,
        actionUrl: _actionUrlController.text.trim().isEmpty
            ? null
            : _actionUrlController.text.trim(),
      );

      if (!mounted) return;
      final totalRecipients = result['totalRecipients'] as int? ?? 0;
      final notificationId = result['notificationId'];
      _show(
        'Notification #$notificationId sent to $totalRecipients $_targetRole recipient(s).',
      );
      _titleController.clear();
      _messageController.clear();
      _productIdController.clear();
      _actionUrlController.clear();
    } catch (error) {
      if (mounted) _show(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketing Notification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Create Marketing Notification',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Broadcast a deal, discount, flash sale, or voucher to the selected role.',
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: _types
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _targetRole,
            decoration: const InputDecoration(
              labelText: 'Target role',
              border: OutlineInputBorder(),
            ),
            items: _targetRoles
                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _targetRole = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _productIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Related product ID (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _actionUrlController,
            decoration: const InputDecoration(
              labelText: 'Action URL (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'SENDING...' : 'BROADCAST'),
          ),
        ],
      ),
    );
  }
}
