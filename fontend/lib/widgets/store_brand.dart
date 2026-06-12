import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StoreBrand extends StatelessWidget {
  final Color color;
  final double size;
  final bool showName;

  const StoreBrand({
    super.key,
    this.color = AppColors.black,
    this.size = 30,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * .72,
          child: CustomPaint(painter: _StripesPainter(color)),
        ),
        if (showName) ...[
          const SizedBox(width: 8),
          Text(
            'ADIDAS',
            style: TextStyle(
              color: color,
              fontSize: size * .62,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
        ],
      ],
    );
  }
}

class _StripesPainter extends CustomPainter {
  final Color color;

  const _StripesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final stripeWidth = size.width * .22;
    for (var index = 0; index < 3; index++) {
      final left = index * size.width * .31;
      final top = size.height * (.55 - index * .2);
      canvas.drawParallelogram(
        Offset(left, top),
        Size(stripeWidth, size.height - top),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripesPainter oldDelegate) =>
      oldDelegate.color != color;
}

extension on Canvas {
  void drawParallelogram(Offset offset, Size size, Paint paint) {
    final slant = size.width * .35;
    final path = Path()
      ..moveTo(offset.dx + slant, offset.dy)
      ..lineTo(offset.dx + size.width, offset.dy)
      ..lineTo(offset.dx + size.width - slant, offset.dy + size.height)
      ..lineTo(offset.dx, offset.dy + size.height)
      ..close();
    drawPath(path, paint);
  }
}

class StoreSectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StoreSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!.toUpperCase(),
              style: const TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}
