import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../providers/booking_provider.dart';

class BookingTrackingScreen extends ConsumerWidget {
  const BookingTrackingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Track Booking')),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Not found'));
          }
          final steps = [
            ('Booked', BookingStatus.pending),
            ('Confirmed', BookingStatus.confirmed),
            ('In Progress', BookingStatus.inProgress),
            ('Completed', BookingStatus.completed),
          ];
          final currentIndex = steps.indexWhere((s) => s.$2 == booking.status);

          return ContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.serviceTitle ?? 'Booking',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('MMM d, yyyy').format(booking.eventDate),
                  style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 32),
                ...steps.asMap().entries.map((entry) {
                  final i = entry.key;
                  final (label, _) = entry.value;
                  final isActive = i <= currentIndex;
                  return Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isActive ? colors.primaryGradient : null,
                          color: isActive ? null : colors.border,
                        ),
                        child: isActive
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }),
                const Spacer(),
                if (booking.chatRoomId != null)
                  GradientButton(
                    label: 'Chat with Seller',
                    icon: Icons.chat,
                    onPressed: () => context.push('/chat/${booking.chatRoomId}'),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
