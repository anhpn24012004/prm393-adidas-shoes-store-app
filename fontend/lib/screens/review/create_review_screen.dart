import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final _commentController = TextEditingController();
  final _reviewService = ReviewService();
  int _rating = 5;
  int? _productId;
  int? _reviewId;
  bool _editMode = false;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    if (_productId != null) return;

    if (argument is int) {
      _productId = argument;
    } else if (argument is Map) {
      _productId = argument['productId'] as int?;
      _reviewId = argument['reviewId'] as int?;
      _rating = argument['rating'] as int? ?? 5;
      _commentController.text = argument['comment']?.toString() ?? '';
      _editMode = _reviewId != null;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (AppConfig.currentUserId <= 0) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    if (_productId == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your review.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      if (_editMode) {
        await _reviewService.updateReview(
          reviewId: _reviewId!,
          rating: _rating,
          comment: _commentController.text.trim(),
        );
      } else {
        await _reviewService.createReview(
          CreateReviewRequest(
            productId: _productId!,
            rating: _rating,
            comment: _commentController.text.trim(),
          ),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editMode ? 'SỬA ĐÁNH GIÁ' : 'VIẾT ĐÁNH GIÁ')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            _editMode ? 'CẬP NHẬT\nTRẢI NGHIỆM.' : 'BẠN THẤY\nTHẾ NÀO?',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 28),
          Row(
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade700,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _commentController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Chia sẻ trải nghiệm của bạn',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(
              _loading
                  ? 'ĐANG GỬI...'
                  : _editMode
                      ? 'LƯU ĐÁNH GIÁ'
                      : 'GỬI ĐÁNH GIÁ',
            ),
          ),
        ],
      ),
    );
  }
}
