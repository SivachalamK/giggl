import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/glass_card.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final bookingsAsync = ref.watch(sellerBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ContentContainer(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: colors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back! 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  bookingsAsync.when(
                    data: (bookings) => Text(
                      '${bookings.length} active bookings',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: Responsive.value(context, mobile: 2, desktop: 4).round(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _DashCard(
                  icon: Icons.add_circle_outline,
                  label: 'Add Service',
                  onTap: () => context.push('/seller/service/new'),
                ),
                _DashCard(
                  icon: Icons.calendar_month,
                  label: 'Availability',
                  onTap: () => context.push('/seller/availability'),
                ),
                _DashCard(
                  icon: Icons.receipt_long,
                  label: 'Bookings',
                  onTap: () => context.push('/seller/bookings'),
                ),
                _DashCard(
                  icon: Icons.analytics,
                  label: 'Earnings',
                  onTap: () => context.push('/seller/earnings'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/seller/service/new'),
        label: const Text('New Service'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: colors.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
