import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProductRating extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final double iconSize;

  const ProductRating({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    this.iconSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount <= 0) {
      return const Text(
        'Chưa có đánh giá',
        style: TextStyle(color: AppColors.muted, fontSize: 12),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final value = index + 1;
          final icon = averageRating >= value
              ? Icons.star
              : averageRating >= value - 0.5
                  ? Icons.star_half
                  : Icons.star_border;

          return Icon(icon, size: iconSize, color: Colors.amber.shade700);
        }),
        const SizedBox(width: 4),
        Text(
          '${averageRating.toStringAsFixed(1)} ($reviewCount)',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}
