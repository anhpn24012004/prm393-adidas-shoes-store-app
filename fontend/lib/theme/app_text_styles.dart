import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const display = TextStyle(
    fontSize: 42,
    height: 1.02,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
  );

  static const pageTitle = TextStyle(
    fontSize: 30,
    height: 1.12,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
  );

  static const sectionTitle = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
  );

  static const body = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.ink,
  );

  static const caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    color: AppColors.muted,
    fontWeight: FontWeight.w600,
  );

  static const price = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w900,
    color: AppColors.black,
  );
}
