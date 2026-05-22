import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
