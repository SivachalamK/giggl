import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../providers/booking_provider.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }
          return ContentContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryRow('Service', booking.serviceTitle ?? '-'),
                _SummaryRow(
                  'Date',
                  DateFormat('MMM d, yyyy').format(booking.eventDate),
                ),
                _SummaryRow('Location', booking.eventLocation ?? 'TBD'),
                const Divider(height: 32),
                _SummaryRow(
                  'Total',
                  '${AppConstants.currencySymbol}${booking.totalAmount.toStringAsFixed(0)}',
                  bold: true,
                ),
                _SummaryRow(
                  'Advance Due',
                  '${AppConstants.currencySymbol}${booking.advanceAmount.toStringAsFixed(0)}',
                  bold: true,
                  highlight: true,
                ),
                const Spacer(),
                GradientButton(
                  label: 'Pay Advance',
                  onPressed: () => context.push('/payment/$bookingId'),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.bold = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
              fontSize: bold ? 18 : 14,
              color: highlight ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
