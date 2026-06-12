import 'package:flutter/material.dart';

import '../providers/badge_notifier.dart';

class CartWishlistBadges extends StatelessWidget {
  const CartWishlistBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BadgeNotifier.instance,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BadgeIconButton(
              icon: Icons.favorite_border,
              count: BadgeNotifier.instance.wishlistCount,
              onPressed: () {
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
            _BadgeIconButton(
              icon: Icons.shopping_cart_outlined,
              count: BadgeNotifier.instance.cartCount,
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        );
      },
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  const _BadgeIconButton({
    required this.icon,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(icon: Icon(icon), onPressed: onPressed),
        if (count > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
