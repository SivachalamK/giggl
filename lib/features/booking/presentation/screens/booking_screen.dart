import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _book() async {
    final service = await ref.read(serviceDetailProvider(widget.serviceId).future);
    final user = ref.read(currentUserProvider);
    if (service == null || user == null) return;

    final booking = await ref.read(bookingNotifierProvider.notifier).create(
          customerId: user.id,
          sellerId: service.sellerId,
          serviceId: service.id,
          eventDate: _eventDate,
          totalAmount: service.price,
          eventLocation: _locationController.text,
          notes: _notesController.text,
        );

    if (booking != null && mounted) {
      context.push('/checkout/${booking.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceAsync = ref.watch(serviceDetailProvider(widget.serviceId));
    final isLoading = ref.watch(bookingNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Service')),
      body: serviceAsync.when(
        data: (service) {
          if (service == null) {
            return const Center(child: Text('Service not found'));
          }
          final advance = service.price * AppConstants.advancePaymentPercent;
          return ContentContainer(
            child: ListView(
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.currencySymbol}${service.price.toStringAsFixed(0)} total',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event Date'),
                  subtitle: Text(DateFormat('EEE, MMM d, yyyy').format(_eventDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _eventDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setState(() => _eventDate = date);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationController,
                  label: 'Event Location',
                  hint: 'Venue address',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Special requirements...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Advance (25%)'),
                      Text(
                        '${AppConstants.currencySymbol}${advance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  label: 'Continue to Checkout',
                  isLoading: isLoading,
                  onPressed: _book,
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
