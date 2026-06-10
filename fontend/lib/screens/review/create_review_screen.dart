import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  final _userIdController = TextEditingController();
  final _productIdController = TextEditingController();
  final _commentController = TextEditingController();

  final _reviewService = ReviewService();

  int _rating = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _productIdController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreateReviewRequest(
        userId: int.parse(_userIdController.text),
        productId: int.parse(_productIdController.text),
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      final result = await _reviewService.createReview(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tạo review thành công. Review ID: ${result.reviewId}'),
        ),
      );

      _commentController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;

        return IconButton(
          onPressed: () {
            setState(() {
              _rating = starValue;
            });
          },
          icon: Icon(
            starValue <= _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 34,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sản phẩm'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _userIdController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('User ID'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập User ID';
                      }

                      if (int.tryParse(value) == null) {
                        return 'User ID không hợp lệ';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _productIdController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('Product ID'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập Product ID';
                      }

                      if (int.tryParse(value) == null) {
                        return 'Product ID không hợp lệ';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Chọn số sao',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _buildRatingStars(),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: _inputDecoration('Nhận xét'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập nhận xét';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitReview,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.rate_review),
                      label: Text(
                        _isLoading ? 'Đang gửi...' : 'Gửi đánh giá',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}