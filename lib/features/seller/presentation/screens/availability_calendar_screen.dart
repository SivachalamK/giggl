import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AvailabilityCalendarScreen extends ConsumerStatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  ConsumerState<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends ConsumerState<AvailabilityCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  final Set<DateTime> _unavailable = {};

  Future<void> _toggleDay(DateTime selectedDay, DateTime focusedDay) async {
    final day = selectedDay;
    setState(() => _focusedDay = focusedDay);
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() {
      final normalized = DateTime(day.year, day.month, day.day);
      if (_unavailable.contains(normalized)) {
        _unavailable.remove(normalized);
      } else {
        _unavailable.add(normalized);
      }
    });

    try {
      await Supabase.instance.client.from('seller_availability').upsert({
        'seller_id': userId,
        'date': day.toIso8601String().split('T').first,
        'is_available': !_unavailable.contains(
          DateTime(day.year, day.month, day.day),
        ),
      });
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => _unavailable.contains(
                DateTime(day.year, day.month, day.day),
              ),
              onDaySelected: _toggleDay,
              onPageChanged: (day) => _focusedDay = day,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(width: 16, height: 16, color: colors.error),
                const SizedBox(width: 8),
                const Text('Unavailable (tap to toggle)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
