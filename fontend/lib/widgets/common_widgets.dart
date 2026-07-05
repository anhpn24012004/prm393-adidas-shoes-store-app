import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'product_rating.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final VoidCallback? onPressed;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 19),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool fullWidth;
  final VoidCallback? onPressed;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.icon,
    this.fullWidth = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final actionText = actionLabel;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.sectionTitle,
          ),
        ),
        if (actionText != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText, maxLines: 1),
          ),
      ],
    );
  }
}

class AppProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 38, color: AppColors.subtle),
      ),
    );

    final resolvedUrl = imageUrl?.trim();
    if (resolvedUrl == null || resolvedUrl.isEmpty) return placeholder;

    return Image.network(
      AppConfig.resolveImageUrl(resolvedUrl),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const AppLoadingState(compact: true);
      },
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class AppProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const AppProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final productName = product.productName.trim().isEmpty
        ? 'Sản phẩm'
        : product.productName;
    final categoryName = product.categoryName?.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final boundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final imageHeight = boundedHeight
            ? (constraints.maxHeight - 132).clamp(120.0, 260.0)
            : 176.0;

        return Material(
          color: AppColors.surface,
          borderRadius: AppRadius.mdBorder,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(
                        color: AppColors.surfaceAlt,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: AppProductImage(
                            imageUrl: product.mainImageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onFavorite,
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(Icons.favorite_border, size: 19),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryName != null && categoryName.isNotEmpty
                            ? categoryName
                            : 'Originals',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 6),
                      ProductRating(
                        averageRating: product.averageRating,
                        reviewCount: product.reviewCount,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatVnd(product.basePrice),
                        style: AppTextStyles.price,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final actionWidget = action;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, height: 1.45),
            ),
            if (actionWidget != null) ...[
              const SizedBox(height: AppSpacing.xl),
              actionWidget,
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline,
      title: 'Đã có lỗi xảy ra',
      message: message,
      action: onRetry == null
          ? null
          : AppOutlinedButton(
              text: 'Thử lại',
              icon: Icons.refresh,
              fullWidth: false,
              onPressed: onRetry,
            ),
    );
  }
}

class AppLoadingState extends StatelessWidget {
  final bool compact;

  const AppLoadingState({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        color: AppColors.surfaceAlt,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Đang tải dữ liệu...',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBadge extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;

  const AppBadge({
    super.key,
    required this.label,
    this.selected = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? AppColors.black
        : color ?? AppColors.surfaceAlt;
    final foreground = selected ? Colors.white : AppColors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: selected ? AppColors.black : AppColors.line),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  final num value;
  final double? fontSize;

  const PriceText(this.value, {super.key, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      formatVnd(value.toDouble()),
      style: AppTextStyles.price.copyWith(fontSize: fontSize),
    );
  }
}
