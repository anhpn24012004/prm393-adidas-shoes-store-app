import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/ai_recommendation_model.dart';
import '../../services/ai_assistant_service.dart';
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
  final _favoriteColorController = TextEditingController();
  final _aiService = AiAssistantService();

  String _gender = 'Nam';
  String _footWidth = 'Bình thường';
  String _purpose = 'Chạy bộ';
  bool _isLoading = false;
  AiRecommendationResponse? _result;

  @override
  void dispose() {
    _footLengthController.dispose();
    _budgetController.dispose();
    _favoriteColorController.dispose();
    super.dispose();
  }

  Future<void> _submitRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final request = AiRecommendationRequest(
        gender: _gender,
        footLengthCm: double.parse(_footLengthController.text),
        footWidth: _footWidth,
        purpose: _purpose,
        budget: double.parse(_budgetController.text),
        favoriteColor: _favoriteColorController.text.trim(),
      );

      final response = await _aiService.getRecommendation(request);

      if (mounted) {
        setState(() => _result = response);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }

  void _goToProduct(AiRecommendedProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.productId),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_outlined, size: 42)),
      );
    }

    return Image.network(
      AppConfig.resolveImageUrl(imageUrl),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
        );
      },
    );
  }

  Widget _buildRecommendedProductCard(AiRecommendedProduct product) {
    return InkWell(
      onTap: () => _goToProduct(product),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 116,
              height: 132,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(8),
                ),
                child: _buildProductImage(product.mainImageUrl),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.categoryName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(label: Text('EU${product.size}')),
                        Chip(label: Text(product.color)),
                        Chip(label: Text('Còn ${product.stockQuantity}')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();

    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kết quả tư vấn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Size đề xuất: ${result.recommendedSize}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              result.advice,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 18),
            const Text(
              'Sản phẩm phù hợp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (result.recommendedProducts.isEmpty)
              const Text('Chưa có sản phẩm phù hợp trong kho.')
            else
              ...result.recommendedProducts.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildRecommendedProductCard(product),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tư vấn chọn giày AI'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: _inputDecoration('Giới tính'),
                        items: const [
                          DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                          DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _gender = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _footLengthController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Chiều dài bàn chân (cm)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập chiều dài bàn chân';
                          }

                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Chiều dài bàn chân không hợp lệ';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _footWidth,
                        decoration: _inputDecoration('Độ rộng bàn chân'),
                        items: const [
                          DropdownMenuItem(value: 'Hẹp', child: Text('Hẹp')),
                          DropdownMenuItem(
                            value: 'Bình thường',
                            child: Text('Bình thường'),
                          ),
                          DropdownMenuItem(value: 'Rộng', child: Text('Rộng')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _footWidth = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _purpose,
                        decoration: _inputDecoration('Mục đích sử dụng'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Chạy bộ',
                            child: Text('Chạy bộ'),
                          ),
                          DropdownMenuItem(
                            value: 'Đi học',
                            child: Text('Đi học'),
                          ),
                          DropdownMenuItem(
                            value: 'Tập gym',
                            child: Text('Tập gym'),
                          ),
                          DropdownMenuItem(
                            value: 'Thời trang',
                            child: Text('Thời trang'),
                          ),
                          DropdownMenuItem(
                            value: 'Đá bóng',
                            child: Text('Đá bóng'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _purpose = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Ngân sách (VND)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập ngân sách';
                          }

                          final number = double.tryParse(value);
                          if (number == null || number <= 0) {
                            return 'Ngân sách không hợp lệ';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _favoriteColorController,
                        decoration: _inputDecoration('Màu sắc yêu thích'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập màu sắc yêu thích';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _submitRecommendation,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome),
                          label: Text(
                            _isLoading
                                ? 'Đang tư vấn...'
                                : 'Nhận tư vấn AI',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildResult(),
          ],
        ),
      ),
    );
  }
}
