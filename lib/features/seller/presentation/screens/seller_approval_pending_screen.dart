import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';

class SellerApprovalPendingScreen extends StatelessWidget {
  const SellerApprovalPendingScreen({super.key});

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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: colors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 64,
                  ),
                )
                    .animate()
                    .scale(
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                    )
                    .then()
                    .shimmer(duration: 1200.ms),
                const SizedBox(height: 32),
                Text(
                  'Application Under Review',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 300.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 16),
                Text(
                  'Thank you for registering as a seller! Our team is reviewing your application and documents.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                        height: 1.6,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: colors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What happens next?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        number: '1',
                        title: 'Document Verification',
                        subtitle: 'We verify your Aadhaar and business details',
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        number: '2',
                        title: 'Background Check',
                        subtitle: 'Quick background verification (24-48 hours)',
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      _StepItem(
                        number: '3',
                        title: 'Approval',
                        subtitle:
                            'Once approved, you can start accepting bookings',
                        colors: colors,
                      ),
                    ],
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: colors.success, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You\'ll receive an email once the review is complete.',
                          style: TextStyle(
                            color: colors.success,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 48),
                GradientButton(
                  label: 'Back to Login',
                  onPressed: () => context.go('/login?role=seller'),
                )
                    .animate(delay: 700.ms)
                    .fadeIn()
                    .slideY(begin: 0.2, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  final String number;
  final String title;
  final String subtitle;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: colors.primaryGradient,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
