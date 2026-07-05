import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_config.dart';
import '../../models/ai_recommendation_model.dart';
import '../../providers/badge_notifier.dart';
import '../../services/ai_assistant_service.dart';
import '../../services/auth_storage.dart';
import '../../services/cart_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_formatter.dart';
import '../product/product_detail_screen.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _footLengthController = TextEditingController();
  final _budgetController = TextEditingController();
  final _aiService = AiAssistantService();
  final _cartService = CartService();
  final _authStorage = AuthStorage();

  final _genders = const ['Nam', 'Nữ', 'Unisex'];
  final _footWidths = const ['Hẹp', 'Bình thường', 'Rộng'];
  final _purposes = const [
    'Chạy bộ',
    'Đi học',
    'Tập gym',
    'Thời trang',
    'Đá bóng',
  ];
  final _colors = const [
    _ColorOption(label: 'Đen', value: 'black'),
    _ColorOption(label: 'Trắng', value: 'white'),
    _ColorOption(label: 'Xám', value: 'gray'),
    _ColorOption(label: 'Xanh', value: 'blue'),
    _ColorOption(label: 'Đỏ', value: 'red'),
    _ColorOption(label: 'Không quan trọng', value: ''),
  ];

  String _gender = 'Nam';
  String _footWidth = 'Bình thường';
  String _purpose = 'Chạy bộ';
  String _favoriteColor = '';
  bool _isLoading = false;
  String? _errorMessage;
  AiRecommendationResponse? _result;

  @override
  void dispose() {
    _footLengthController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submitRecommendation() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final response = await _aiService.getRecommendation(
        AiRecommendationRequest(
          gender: _gender,
          footLengthCm: _parseNumber(_footLengthController.text),
          footWidth: _footWidth,
          purpose: _purpose,
          budget: _budgetController.text.trim().isEmpty
              ? 0
              : _parseMoney(_budgetController.text),
          favoriteColor: _favoriteColor,
        ),
      );

      if (mounted) {
        setState(() => _result = response);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Hệ thống tư vấn đang gặp sự cố. Vui lòng thử lại sau.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addToCart(AiRecommendedProduct product) async {
    final token = await _authStorage.getToken();
    final userId = await _authStorage.getUserId();

    if (!mounted) return;
    if (token == null || userId == null || userId <= 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (product.stockQuantity <= 0) {
      _showMessage('Sản phẩm đang hết hàng.');
      return;
    }

    try {
      AppConfig.currentUserId = userId;
      final totalItems = await _cartService.addToCart(
        userId: userId,
        variantId: product.variantId,
        quantity: 1,
      );
      BadgeNotifier.instance.setCartCount(totalItems);
      if (mounted) {
        _showMessage('Đã thêm vào giỏ hàng ($totalItems sản phẩm).');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Không thể thêm vào giỏ. Vui lòng thử lại.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _parseNumber(String value) {
    return double.parse(value.trim().replaceAll(',', '.'));
  }

  double _parseMoney(String value) {
    final normalized = value.replaceAll('.', '').replaceAll(',', '').trim();
    return double.parse(normalized);
  }

  String? _validateFootLength(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Chiều dài bàn chân không được bỏ trống';
    }

    final number = double.tryParse(value.trim().replaceAll(',', '.'));
    if (number == null) {
      return 'Chiều dài bàn chân phải là số';
    }

    if (number < 20 || number > 32) {
      return 'Chiều dài hợp lệ từ 20 đến 32 cm';
    }

    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final number = double.tryParse(
      value.replaceAll('.', '').replaceAll(',', '').trim(),
    );
    if (number == null || number <= 0) {
      return 'Ngân sách phải là số dương';
    }

    return null;
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      border: const OutlineInputBorder(borderRadius: AppRadius.mdBorder),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: const BorderSide(color: AppColors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mdBorder,
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      filled: true,
      fillColor: AppColors.surface,
    );
  }

  void _goToProduct(AiRecommendedProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.productId),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: AppRadius.lgBorder,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tư vấn chọn giày AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Nhập thông tin bàn chân và nhu cầu của bạn, AI sẽ gợi ý size và sản phẩm phù hợp.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              label: 'Giới tính',
              value: _gender,
              values: _genders,
              onChanged: (value) => setState(() => _gender = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _footLengthController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              decoration: _inputDecoration(
                label: 'Chiều dài bàn chân',
                hint: 'Ví dụ: 25.5',
                suffix: 'cm',
              ),
              validator: _validateFootLength,
            ),
            const SizedBox(height: 8),
            Text(
              'Đo từ gót chân đến đầu ngón chân dài nhất. Nên chừa thêm khoảng 0.5 cm nếu muốn đi thoải mái.',
              style: TextStyle(color: Colors.grey.shade700, height: 1.35),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Độ rộng bàn chân',
              value: _footWidth,
              values: _footWidths,
              onChanged: (value) => setState(() => _footWidth = value),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Mục đích sử dụng',
              value: _purpose,
              values: _purposes,
              onChanged: (value) => setState(() => _purpose = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: _inputDecoration(
                label: 'Ngân sách tối đa',
                hint: 'Ví dụ: 2000000',
                suffix: 'đ',
              ),
              validator: _validateBudget,
            ),
            const SizedBox(height: 16),
            const Text(
              'Màu yêu thích',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final selected = color.value == _favoriteColor;
                return ChoiceChip(
                  label: Text(color.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _favoriteColor = color.value);
                  },
                  selectedColor: AppColors.black,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitRecommendation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading
                      ? 'AI đang phân tích size và sản phẩm phù hợp...'
                      : '✨ Nhận tư vấn AI',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(label: label),
      items: values
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget _buildResult() {
    final result = _result;

    if (_errorMessage != null) {
      return _InfoStateCard(
        icon: Icons.error_outline,
        title: 'Không thể tư vấn lúc này',
        message: _errorMessage ?? '',
      );
    }

    if (_isLoading) {
      return const _InfoStateCard(
        icon: Icons.auto_awesome,
        title: 'Đang phân tích',
        message: 'AI đang phân tích size và sản phẩm phù hợp...',
      );
    }

    if (result == null) {
      return const _InfoStateCard(
        icon: Icons.saved_search,
        title: 'Sẵn sàng tư vấn',
        message:
            'Điền thông tin bên trái để nhận size, lời khuyên và sản phẩm phù hợp từ kho hàng thật.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.straighten,
                title: 'Size đề xuất',
              ),
              const SizedBox(height: 14),
              Text(
                'Size phù hợp: EU ${result.recommendedSize}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(result.sizeAdvice, style: const TextStyle(height: 1.45)),
              if (result.fitWarning?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _WarningBox(message: result.fitWarning ?? ''),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _SectionTitle(
                      icon: Icons.psychology_alt_outlined,
                      title: 'Phân tích AI',
                    ),
                  ),
                  _Badge(
                    label: result.isAiGenerated
                        ? 'Gemini AI'
                        : 'Gợi ý mặc định',
                    dark: result.isAiGenerated,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(result.summary, style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.tips_and_updates_outlined,
                title: 'Mẹo chọn giày',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: result.buyingTips
                    .map((tip) => Chip(label: Text(tip)))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle(
                icon: Icons.shopping_bag_outlined,
                title: 'Top sản phẩm phù hợp',
              ),
              const SizedBox(height: 14),
              if (result.warnings.isNotEmpty) ...[
                _WarningsPanel(warnings: result.warnings),
                const SizedBox(height: 14),
              ],
              if (result.recommendations.isEmpty)
                const _EmptyProducts()
              else
                ...result.recommendations.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecommendedProductCard(
                      product: product,
                      onView: () => _goToProduct(product),
                      onAddToCart: () => _addToCart(product),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tư vấn chọn giày AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    if (!wide) {
                      return Column(
                        children: [
                          _buildFormCard(),
                          const SizedBox(height: 18),
                          _buildResult(),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 400, child: _buildFormCard()),
                        const SizedBox(width: 18),
                        Expanded(child: _buildResult()),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorOption {
  final String label;
  final String value;

  const _ColorOption({required this.label, required this.value});
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: AppColors.line),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool dark;

  const _Badge({required this.label, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.black : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dark ? Colors.white : Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  final String message;

  const _WarningBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: const Color(0xFFFFD88A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}

class _WarningsPanel extends StatelessWidget {
  final List<String> warnings;

  const _WarningsPanel({required this.warnings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: const Color(0xFFFFD88A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: warnings
            .map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(warning, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InfoStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InfoStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 34),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.mdBorder,
      ),
      child: const Text(
        "Chưa tìm thấy sản phẩm phù hợp với tiêu chí của bạn. Hãy thử tăng ngân sách hoặc chọn màu 'Không quan trọng'.",
        style: TextStyle(height: 1.45),
      ),
    );
  }
}

class _RecommendedProductCard extends StatelessWidget {
  final AiRecommendedProduct product;
  final VoidCallback onView;
  final VoidCallback onAddToCart;

  const _RecommendedProductCard({
    required this.product,
    required this.onView,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final image = ClipRRect(
          borderRadius: AppRadius.mdBorder,
          child: _ProductImage(imageUrl: product.imageUrl),
        );

        final details = _ProductDetails(
          product: product,
          onView: onView,
          onAddToCart: onAddToCart,
        );

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: AppColors.line),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(aspectRatio: 16 / 10, child: image),
                    const SizedBox(height: 12),
                    details,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 150, height: 150, child: image),
                    const SizedBox(width: 14),
                    Expanded(child: details),
                  ],
                ),
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageUrl?.trim();
    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceAlt,
        child: const Center(child: Icon(Icons.image_outlined, size: 42)),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(resolvedUrl),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.surfaceAlt,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 42),
          ),
        );
      },
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final AiRecommendedProduct product;
  final VoidCallback onView;
  final VoidCallback onAddToCart;

  const _ProductDetails({
    required this.product,
    required this.onView,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _Badge(label: 'Phù hợp ${product.matchScore}%', dark: true),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          [
            if (product.categoryName?.trim().isNotEmpty == true)
              product.categoryName ?? '',
            'EU ${product.size}',
            product.color,
          ].join(' • '),
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Text(
          formatVnd(product.price, suffix: ' đ'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: product.reasonTags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        Text(product.reason, style: const TextStyle(height: 1.4)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Xem chi tiết'),
            ),
            ElevatedButton.icon(
              onPressed: product.stockQuantity > 0 ? onAddToCart : null,
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Thêm vào giỏ'),
            ),
          ],
        ),
      ],
    );
  }
}
