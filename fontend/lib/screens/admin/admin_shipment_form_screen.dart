import 'package:flutter/material.dart';

import '../../localization/app_localization.dart';
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
          carrier: '',
          trackingNumber: '',
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
                ? context.tr('shipmentSaved')
                : context.tr('trackingUpdated'),
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
          widget.createMode
              ? context.tr('createShipment')
              : context.tr('updateTrackingInfo'),
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
              decoration: InputDecoration(
                labelText: context.tr('orderId'),
                border: const OutlineInputBorder(),
              ),
              validator: widget.createMode
                  ? (value) {
                      final orderId = int.tryParse(value?.trim() ?? '');
                      if (orderId == null || orderId <= 0) {
                        return context.tr('orderIdRequired');
                      }
                      return null;
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            if (!widget.createMode) ...[
              TextFormField(
                controller: _carrierController,
                enabled: !_submitting,
                decoration: InputDecoration(
                  labelText: context.tr('carrier'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.tr('carrierRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trackingController,
                enabled: !_submitting,
                decoration: InputDecoration(
                  labelText: context.tr('trackingNumber'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return context.tr('trackingNumberRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estimatedController,
                enabled: !_submitting,
                decoration: InputDecoration(
                  labelText: context.tr('estimatedDelivery'),
                  helperText: context.tr('optionalDateFormat'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                enabled: !_submitting,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.tr('note'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
            ],
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
                        widget.createMode
                            ? 'Create GHN shipment'
                            : context.tr('saveChanges'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
