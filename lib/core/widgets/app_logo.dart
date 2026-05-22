import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          '🎉',
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}
