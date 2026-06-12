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
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final argument = ModalRoute.of(context)?.settings.arguments;
    _productId ??= argument is int ? argument : null;
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
      await _reviewService.createReview(
        CreateReviewRequest(
          userId: AppConfig.currentUserId,
          productId: _productId!,
          rating: _rating,
          comment: _commentController.text.trim(),
        ),
      );
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
      appBar: AppBar(title: const Text('WRITE A REVIEW')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'HOW DID\nTHEY FEEL?',
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
              labelText: 'Share your experience',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'SUBMITTING...' : 'SUBMIT REVIEW'),
          ),
        ],
      ),
    );
  }
}
