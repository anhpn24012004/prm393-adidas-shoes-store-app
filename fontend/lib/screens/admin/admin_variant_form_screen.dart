import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';

class AdminVariantFormScreen extends StatefulWidget {
  final int productId;
  final ProductVariantModel? variant;

  const AdminVariantFormScreen({
    super.key,
    required this.productId,
    this.variant,
  });

  @override
  State<AdminVariantFormScreen> createState() => _AdminVariantFormScreenState();
}

class _AdminVariantFormScreenState extends State<AdminVariantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();

  bool _isActive = true;
  bool _isSubmitting = false;

  bool get isEditMode => widget.variant != null;

  @override
  void initState() {
    super.initState();
    final variant = widget.variant;
    if (variant != null) {
      _sizeController.text = variant.size;
      _colorController.text = variant.color;
      _priceController.text = variant.price.toStringAsFixed(0);
      _stockController.text = variant.stockQuantity.toString();
      _skuController.text = variant.sku ?? '';
      _isActive = variant.isActive;
    }
  }

  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final size = _sizeController.text.trim();
      final color = _colorController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final stockQuantity = int.parse(_stockController.text.trim());
      final sku = _skuController.text.trim();

      if (isEditMode) {
        await _productService.updateVariant(
          variantId: widget.variant!.variantId,
          size: size,
          color: color,
          imageUrl:
              widget.variant!.color.trim().toLowerCase() ==
                  color.toLowerCase()
              ? widget.variant!.imageUrl
              : null,
          price: price,
          stockQuantity: stockQuantity,
          sku: sku.isEmpty ? null : sku,
          isActive: _isActive,
        );
      } else {
        await _productService.createVariant(
          productId: widget.productId,
          size: size,
          color: color,
          price: price,
          stockQuantity: stockQuantity,
          sku: sku.isEmpty ? null : sku,
          isActive: _isActive,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool requiredField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (requiredField && text.isEmpty) return '$label is required';
        if (label == 'Price') {
          final price = double.tryParse(text);
          if (price == null || price <= 0) {
            return 'Price must be greater than 0';
          }
        }
        if (label == 'Stock quantity') {
          final stock = int.tryParse(text);
          if (stock == null || stock < 0) {
            return 'Stock quantity must be a valid number';
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditMode ? 'Edit variant' : 'Add variant';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Define size, color, price and stock for this product.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 620;
                        final fields = [
                          _buildTextField(
                            controller: _sizeController,
                            label: 'Size',
                            requiredField: true,
                          ),
                          _buildTextField(
                            controller: _colorController,
                            label: 'Color',
                            requiredField: true,
                          ),
                          _buildTextField(
                            controller: _priceController,
                            label: 'Price',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextField(
                            controller: _stockController,
                            label: 'Stock quantity',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                          ),
                        ];

                        if (!wide) {
                          return Column(
                            children: [
                              for (final field in fields) ...[
                                field,
                                const SizedBox(height: 14),
                              ],
                            ],
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: fields[0]),
                                const SizedBox(width: 14),
                                Expanded(child: fields[1]),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(child: fields[2]),
                                const SizedBox(width: 14),
                                Expanded(child: fields[3]),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(controller: _skuController, label: 'SKU'),
                    const SizedBox(height: 14),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Active variant',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: const Text(
                        'Inactive variants cannot be selected by customers.',
                      ),
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const CircularProgressIndicator()
                                : Text(
                                    isEditMode ? 'Save variant' : 'Add variant',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
