import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/glass_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.background, colors.surface],
          ),
        ),
        child: SafeArea(
          child: ContentContainer(
            child: Column(
              children: [
                const SizedBox(height: 40),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'Welcome to ${AppConstants.appName}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),
                const SizedBox(height: 8),
                Text(
                  'How would you like to use Giggl?',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 40),
                _RoleCard(
                  icon: Icons.celebration,
                  title: 'Book Services',
                  subtitle: 'Find photographers, caterers & more for your events',
                  onTap: () => context.go('/login?role=customer'),
                ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1, end: 0),
                const SizedBox(height: 16),
                _RoleCard(
                  icon: Icons.storefront,
                  title: 'Offer Services',
                  subtitle: 'Register as a seller and grow your business',
                  onTap: () => context.go('/login?role=seller'),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/login?role=admin'),
                  child: Text(
                    'Admin Login',
                    style: TextStyle(color: colors.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: colors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary),
        ],
      ),
    );
  }
}
