import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../buttons/gradient_button.dart';

class AppDialog {
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
  }) {
    final colors = AppColors.of(context);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          GradientButton(
            label: confirmLabel,
            onPressed: () => Navigator.pop(ctx, true),
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }
}
