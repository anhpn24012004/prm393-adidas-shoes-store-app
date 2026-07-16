import 'package:flutter/material.dart';

import '../../models/product_detail_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'admin_variant_form_screen.dart';

class AdminVariantListScreen extends StatefulWidget {
  final ProductModel product;
  final bool fromCreateFlow;

  const AdminVariantListScreen({
    super.key,
    required this.product,
    this.fromCreateFlow = false,
  });

  @override
  State<AdminVariantListScreen> createState() => _AdminVariantListScreenState();
}

class _AdminVariantListScreenState extends State<AdminVariantListScreen> {
  final ProductService _productService = ProductService();
  late Future<List<ProductVariantModel>> _variantsFuture;

  @override
  void initState() {
    super.initState();
    _loadVariants();
  }

  void _loadVariants() {
    _variantsFuture = _productService.getVariantsByProduct(
      widget.product.productId,
    );
  }

  Future<void> _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminVariantFormScreen(productId: widget.product.productId),
      ),
    );
    if (result == true) setState(_loadVariants);
  }

  Future<void> _goToEdit(ProductVariantModel variant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminVariantFormScreen(
          productId: widget.product.productId,
          variant: variant,
        ),
      ),
    );
    if (result == true) setState(_loadVariants);
  }

  Future<void> _deleteVariant(ProductVariantModel variant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete variant'),
        content: Text('Delete Size ${variant.size} - ${variant.color}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _productService.deleteVariant(variant.variantId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Variant deleted')));
      setState(_loadVariants);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _reviewAndPublish() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/admin/products',
      (route) => false,
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<ProductVariantModel>>(
      future: _variantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final variants = snapshot.data ?? [];
        final activeCount = variants
            .where((variant) => variant.isActive)
            .length;
        final totalStock = variants.fold<int>(
          0,
          (sum, variant) => sum + variant.stockQuantity,
        );
        final outOfStock = variants
            .where((variant) => variant.stockQuantity <= 0)
            .length;

        if (variants.isEmpty) {
          return _EmptyState(onAdd: _goToCreate);
        }

        return RefreshIndicator(
          onRefresh: () async => setState(_loadVariants),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _VariantSummary(
                total: variants.length,
                active: activeCount,
                stock: totalStock,
                outOfStock: outOfStock,
              ),
              const SizedBox(height: 14),
              ...variants.map(
                (variant) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VariantCard(
                    variant: variant,
                    onEdit: () => _goToEdit(variant),
                    onDelete: () => _deleteVariant(variant),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.fromCreateFlow
        ? 'Step 3: Add Variants'
        : 'Variants - ${widget.product.productName}';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _PageHeader(
                  title: title,
                  subtitle: widget.fromCreateFlow
                      ? 'Add an active variant with stock before publishing.'
                      : 'Manage sizes, colors, prices and stock.',
                ),
              ),
              Expanded(child: _buildBody()),
              if (widget.fromCreateFlow)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reviewAndPublish,
                      icon: const Icon(Icons.fact_check_outlined),
                      label: const Text('Review & Publish'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Add variant',
        onPressed: _goToCreate,
        icon: const Icon(Icons.add),
        label: const Text('Add variant'),
      ),
    );
  }
}

class _VariantSummary extends StatelessWidget {
  final int total;
  final int active;
  final int stock;
  final int outOfStock;

  const _VariantSummary({
    required this.total,
    required this.active,
    required this.stock,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final cards = [
          ('Total variants', '$total', Icons.grid_view_outlined),
          ('Active variants', '$active', Icons.verified_outlined),
          ('Total stock', '$stock', Icons.inventory_2_outlined),
          ('Out of stock', '$outOfStock', Icons.warning_amber_outlined),
        ];

        return GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final card = cards[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  Icon(card.$3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          card.$2,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          card.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _VariantCard extends StatelessWidget {
  final ProductVariantModel variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VariantCard({
    required this.variant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'Size\n${variant.size}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ColorBadge(label: variant.color),
                    _StockBadge(stock: variant.stockQuantity),
                    _StatusBadge(active: variant.isActive),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  formatVnd(variant.price),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  'SKU: ${variant.sku?.isNotEmpty == true ? variant.sku : 'N/A'}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            tooltip: 'Edit variant',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 6),
          IconButton.outlined(
            tooltip: 'Delete variant',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _ColorBadge extends StatelessWidget {
  final String label;

  const _ColorBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label), visualDensity: VisualDensity.compact);
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;

  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final color = stock == 0
        ? const Color(0xFF8A1F1F)
        : stock <= 10
        ? const Color(0xFF805C00)
        : const Color(0xFF1F7A4D);

    return Chip(
      label: Text('Stock: $stock'),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withValues(alpha: .11),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w900),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;

  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(active ? 'Active' : 'Inactive'),
      visualDensity: VisualDensity.compact,
      backgroundColor: active ? const Color(0xFFE7F6ED) : AppColors.surface,
      labelStyle: TextStyle(
        color: active ? const Color(0xFF1F7A4D) : AppColors.muted,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 56),
            const SizedBox(height: 12),
            const Text(
              'No variants yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add at least one active variant with stock before publishing.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add first variant'),
            ),
          ],
        ),
      ),
    );
  }
}
