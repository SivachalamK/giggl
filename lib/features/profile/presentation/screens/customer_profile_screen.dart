import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final bookingsAsync = ref.watch(customerBookingsProvider);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ContentContainer(
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: colors.primary,
                child: Text(
                  (user?.fullName ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.fullName ?? 'Guest',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (user?.email != null)
              Center(
                child: Text(
                  user!.email!,
                  style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                ),
              ),
            const SizedBox(height: 32),
            _ProfileTile(
              icon: Icons.receipt_long,
              title: 'My Bookings',
              onTap: () => _showBookings(context, ref),
            ),
            _ProfileTile(
              icon: Icons.chat_outlined,
              title: 'Messages',
              onTap: () => context.push('/chats'),
            ),
            _ProfileTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push('/settings'),
            ),
            _ProfileTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => context.push('/help'),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) context.go('/splash');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookings(BuildContext context, WidgetRef ref) {
    final bookings = ref.read(customerBookingsProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (_, i) {
          final b = bookings[i];
          return ListTile(
            title: Text(b.serviceTitle ?? 'Booking'),
            subtitle: Text(b.status.name),
            onTap: () {
              Navigator.pop(ctx);
              context.push('/booking-tracking/${b.id}');
            },
          );
        },
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
