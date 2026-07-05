import 'package:flutter/material.dart';

abstract final class AppColors {
  // Core Adidas-inspired neutrals. These remain the default UI palette.
  static const black = Color(0xFF111111);
  static const ink = Color(0xFF1F1F1F);
  static const muted = Color(0xFF666666);
  static const subtle = Color(0xFF8A8A8A);
  static const background = Color(0xFFF7F7F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF4F4F4);
  static const line = Color(0xFFE5E5E5);

  // Status colors for admin badges, alerts, and validation states only.
  static const blue = Color(0xFF2563EB);
  static const red = Color(0xFFB42318);
  static const green = Color(0xFF166534);
  static const orange = Color(0xFFC2410C);
  static const yellow = Color(0xFFB7791F);

  static const success = Color(0xFF166534);
  static const warning = Color(0xFF9A6700);
  static const error = Color(0xFFB42318);
  static const info = Color(0xFF2563EB);

  static const danger = error;
}
