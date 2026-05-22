import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart' show AppConstants, BookingStatus;
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class BookingManagementScreen extends ConsumerWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(sellerBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: bookingsAsync.when(
        data: (bookings) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final b = bookings[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(b.serviceTitle ?? 'Booking'),
                subtitle: Text(
                  '${DateFormat('MMM d').format(b.eventDate)} • ${b.status.name}',
                ),
                trailing: Text(
                  '${AppConstants.currencySymbol}${b.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () => _showActions(context, ref, b.id, b.status.name),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  void _showActions(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Confirm'),
            onTap: () async {
              await ref.read(bookingRepositoryProvider).updateStatus(
                    id,
                    BookingStatus.confirmed.name,
                  );
              Navigator.pop(ctx);
              ref.invalidate(sellerBookingsProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text('Mark In Progress'),
            onTap: () async {
              await ref.read(bookingRepositoryProvider).updateStatus(
                    id,
                    BookingStatus.inProgress.name,
                  );
              Navigator.pop(ctx);
              ref.invalidate(sellerBookingsProvider);
            },
          ),
          ListTile(
            leading: const Icon(Icons.done_all),
            title: const Text('Complete'),
            onTap: () async {
              await ref.read(bookingRepositoryProvider).updateStatus(
                    id,
                    BookingStatus.completed.name,
                  );
              Navigator.pop(ctx);
              ref.invalidate(sellerBookingsProvider);
            },
          ),
          if (status != 'cancelled')
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancel'),
              onTap: () async {
                await ref.read(bookingRepositoryProvider).updateStatus(
                      id,
                      BookingStatus.cancelled.name,
                    );
                Navigator.pop(ctx);
                ref.invalidate(sellerBookingsProvider);
              },
            ),
        ],
      ),
    );
  }
}
