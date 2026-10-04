import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

// Shared loading, error and empty states used by every screen.

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.wifi_off_rounded,
      title: "Couldn't load Pokémon",
      message: message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.icon,
    this.image,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData? icon;

  /// Optional illustration shown instead of [icon].
  final Widget? image;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null)
              image!
            else if (icon != null)
              Icon(icon, size: 64, color: AppColors.grey200),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
