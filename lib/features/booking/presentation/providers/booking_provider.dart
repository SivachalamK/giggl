import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/booking_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/booking_repository_impl.dart';

final bookingDetailProvider = FutureProvider.family<BookingModel?, String>(
  (ref, id) => ref.watch(bookingRepositoryProvider).getBooking(id),
);

final customerBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(bookingRepositoryProvider).getCustomerBookings(userId);
});

final sellerBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  return ref.watch(bookingRepositoryProvider).getSellerBookings(userId);
});

class BookingNotifier extends StateNotifier<AsyncValue<BookingModel?>> {
  BookingNotifier(this._repo) : super(const AsyncValue.data(null));

  final BookingRepository _repo;

  Future<BookingModel?> create({
    required String customerId,
    required String sellerId,
    required String serviceId,
    required DateTime eventDate,
    required double totalAmount,
    String? eventLocation,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final booking = await _repo.createBooking(
        customerId: customerId,
        sellerId: sellerId,
        serviceId: serviceId,
        eventDate: eventDate,
        totalAmount: totalAmount,
        eventLocation: eventLocation,
        notes: notes,
      );
      state = AsyncValue.data(booking);
      return booking;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final bookingNotifierProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<BookingModel?>>(
  (ref) => BookingNotifier(ref.watch(bookingRepositoryProvider)),
);
