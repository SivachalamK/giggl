import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../buttons/gradient_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: colors.primaryGradient.scale(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: colors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                label: actionLabel!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension GradientScale on Gradient {
  Gradient scale(double opacity) {
    return LinearGradient(
      begin: (this as LinearGradient).begin,
      end: (this as LinearGradient).end,
      colors: colors
          .map((c) => c.withValues(alpha: opacity))
          .toList(),
    );
  }
}
