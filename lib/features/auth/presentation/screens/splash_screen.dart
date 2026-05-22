import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth?.isAuthenticated ?? false) {
      context.go('/home');
    } else {
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 48)),
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .then()
                  .shimmer(duration: 1200.ms),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              Text(
                AppConstants.appTagline,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
