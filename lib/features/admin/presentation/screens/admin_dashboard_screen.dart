import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/cards/glass_card.dart';

final _pendingSellersProvider = FutureProvider((ref) async {
  return Supabase.instance.client
      .from('sellers')
      .select('*, users(full_name, email)')
      .eq('status', 'pending');
});

final _allBookingsProvider = FutureProvider((ref) async {
  return Supabase.instance.client
      .from('bookings')
      .select('*, services(title)')
      .order('created_at', ascending: false)
      .limit(50);
});

final _revenueProvider = FutureProvider<double>((ref) async {
  final data = await Supabase.instance.client
      .from('payments')
      .select('amount')
      .eq('status', 'completed');
  return (data as List).fold<double>(
    0,
    (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0),
  );
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final sellersAsync = ref.watch(_pendingSellersProvider);
    final revenueAsync = ref.watch(_revenueProvider);
    final bookingsAsync = ref.watch(_allBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ContentContainer(
        child: ListView(
          children: [
            revenueAsync.when(
              data: (revenue) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: colors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${AppConstants.currencySymbol}${revenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pending Seller Approvals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            sellersAsync.when(
              data: (sellers) {
                if (sellers.isEmpty) {
                  return const Text('No pending approvals');
                }
                return Column(
                  children: sellers.map<Widget>((s) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['business_name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(s['users']?['email'] ?? ''),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveSeller(ref, s['user_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectSeller(ref, s['user_id']),
                          ),
                        ],
                      ),
                    ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(e.toString()),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Bookings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            bookingsAsync.when(
              data: (bookings) => Column(
                children: bookings.take(10).map<Widget>((b) {
                  return ListTile(
                    title: Text(b['services']?['title'] ?? 'Booking'),
                    subtitle: Text(b['status'] ?? ''),
                    trailing: Text(
                      '${AppConstants.currencySymbol}${(b['total_amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                    ),
                  );
                }).toList(),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveSeller(WidgetRef ref, String userId) async {
    await Supabase.instance.client
        .from('sellers')
        .update({'status': 'approved'})
        .eq('user_id', userId);
    ref.invalidate(_pendingSellersProvider);
  }

  Future<void> _rejectSeller(WidgetRef ref, String userId) async {
    await Supabase.instance.client
        .from('sellers')
        .update({'status': 'rejected'})
        .eq('user_id', userId);
    ref.invalidate(_pendingSellersProvider);
  }
}
