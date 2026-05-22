import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class EarningsAnalyticsScreen extends ConsumerWidget {
  const EarningsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final bookingsAsync = ref.watch(sellerBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: ContentContainer(
        child: bookingsAsync.when(
          data: (bookings) {
            final total = bookings.fold<double>(
              0,
              (sum, b) => sum + b.paidAmount,
            );
            final monthly = List.generate(6, (i) {
              return bookings
                  .where((b) => b.createdAt.month == DateTime.now().month - (5 - i))
                  .fold<double>(0, (s, b) => s + b.paidAmount);
            });

            return ListView(
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
                        'Total Earnings',
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        '${AppConstants.currencySymbol}${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Monthly Revenue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: monthly.reduce((a, b) => a > b ? a : b) + 1000,
                      barGroups: monthly.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value,
                              gradient: colors.primaryGradient,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][v.toInt() % 6],
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
