import 'package:flutter/material.dart';

import '../../models/shipment_model.dart';
import '../../services/shipment_service.dart';

class AdminShipmentFormScreen extends StatefulWidget {
  final ShipmentDetail? shipment;
  final int? initialOrderId;
  final bool createMode;

  const AdminShipmentFormScreen({
    super.key,
    this.shipment,
    this.initialOrderId,
    required this.createMode,
  });

  @override
  State<AdminShipmentFormScreen> createState() =>
      _AdminShipmentFormScreenState();
}

class _AdminShipmentFormScreenState extends State<AdminShipmentFormScreen> {
  final ShipmentService _shipmentService = ShipmentService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _carrierController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();
  final TextEditingController _estimatedController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _orderIdController.text =
        (widget.initialOrderId ?? widget.shipment?.orderId ?? '').toString();
    if (_orderIdController.text == 'null') {
      _orderIdController.clear();
    }
    _carrierController.text = widget.shipment?.carrier ?? '';
    _trackingController.text = widget.shipment?.trackingNumber ?? '';
    _estimatedController.text = _formatDate(
      widget.shipment?.estimatedDeliveryDate,
    );
    _noteController.text = widget.shipment?.note ?? '';
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _carrierController.dispose();
    _trackingController.dispose();
    _estimatedController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return DateTime.tryParse(trimmed);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    try {
      if (widget.createMode) {
        final orderId = int.parse(_orderIdController.text.trim());

        await _shipmentService.createShipment(
          orderId: orderId,
          carrier: _carrierController.text.trim(),
          trackingNumber: _trackingController.text.trim(),
          estimatedDeliveryDate: _parseDate(_estimatedController.text),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      } else {
        await _shipmentService.updateShipmentTrackingInfo(
          shipmentId: widget.shipment!.shipmentId!,
          carrier: _carrierController.text.trim(),
          trackingNumber: _trackingController.text.trim(),
          estimatedDeliveryDate: _parseDate(_estimatedController.text),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.createMode
                ? 'Shipment saved successfully'
                : 'Tracking info updated successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.createMode ? 'Create Shipment' : 'Update Tracking Info',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _orderIdController,
              enabled: widget.createMode && !_submitting,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Order ID',
                border: OutlineInputBorder(),
              ),
              validator: widget.createMode
                  ? (value) {
                      final orderId = int.tryParse(value?.trim() ?? '');
                      if (orderId == null || orderId <= 0) {
                        return 'Order ID is required';
                      }
                      return null;
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carrierController,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Carrier',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Carrier is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trackingController,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Tracking Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Tracking number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _estimatedController,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Estimated Delivery Date',
                helperText: 'Optional, format: YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              enabled: !_submitting,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.createMode ? 'Create Shipment' : 'Save Changes',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
