import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/booking_model.dart';

abstract class BookingRepository {
  Future<BookingModel> createBooking({
    required String customerId,
    required String sellerId,
    required String serviceId,
    required DateTime eventDate,
    required double totalAmount,
    String? eventLocation,
    String? notes,
  });
  Future<BookingModel?> getBooking(String id);
  Future<List<BookingModel>> getCustomerBookings(String customerId);
  Future<List<BookingModel>> getSellerBookings(String sellerId);
  Future<BookingModel> updateStatus(String id, String status);
  Future<BookingModel> updatePayment(
    String id, {
    required double paidAmount,
    required String paymentStatus,
  });
  Future<String> createChatRoom(String bookingId, String customerId, String sellerId);
}

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<BookingModel> createBooking({
    required String customerId,
    required String sellerId,
    required String serviceId,
    required DateTime eventDate,
    required double totalAmount,
    String? eventLocation,
    String? notes,
  }) async {
    final advanceAmount = totalAmount * AppConstants.advancePaymentPercent;
    final data = {
      'customer_id': customerId,
      'seller_id': sellerId,
      'service_id': serviceId,
      'event_date': eventDate.toIso8601String(),
      'event_location': eventLocation,
      'notes': notes,
      'total_amount': totalAmount,
      'advance_amount': advanceAmount,
      'paid_amount': 0,
      'status': BookingStatus.pending.name,
      'payment_status': PaymentStatus.pending.name,
    };

    final result = await _client.from('bookings').insert(data).select('''
      *,
      services(title),
      sellers(business_name)
    ''').single();

    final map = Map<String, dynamic>.from(result);
    map['service_title'] = map['services']?['title'];
    map['seller_name'] = map['sellers']?['business_name'];

    final booking = BookingModel.fromJson(map);

    final chatRoomId = await createChatRoom(
      booking.id,
      customerId,
      sellerId,
    );

    await _client
        .from('bookings')
        .update({'chat_room_id': chatRoomId})
        .eq('id', booking.id);

    return booking.copyWith(chatRoomId: chatRoomId);
  }

  @override
  Future<BookingModel?> getBooking(String id) async {
    final data = await _client.from('bookings').select('''
      *,
      services(title),
      sellers(business_name)
    ''').eq('id', id).maybeSingle();
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data);
    map['service_title'] = map['services']?['title'];
    map['seller_name'] = map['sellers']?['business_name'];
    return BookingModel.fromJson(map);
  }

  @override
  Future<List<BookingModel>> getCustomerBookings(String customerId) async {
    final data = await _client
        .from('bookings')
        .select('*, services(title), sellers(business_name)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return _mapBookings(data);
  }

  @override
  Future<List<BookingModel>> getSellerBookings(String sellerId) async {
    final data = await _client
        .from('bookings')
        .select('*, services(title), sellers(business_name)')
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);
    return _mapBookings(data);
  }

  @override
  Future<BookingModel> updateStatus(String id, String status) async {
    final result = await _client
        .from('bookings')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .select()
        .single();
    return BookingModel.fromJson(result);
  }

  @override
  Future<BookingModel> updatePayment(
    String id, {
    required double paidAmount,
    required String paymentStatus,
  }) async {
    final result = await _client
        .from('bookings')
        .update({
          'paid_amount': paidAmount,
          'payment_status': paymentStatus,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return BookingModel.fromJson(result);
  }

  @override
  Future<String> createChatRoom(
    String bookingId,
    String customerId,
    String sellerId,
  ) async {
    final result = await _client.from('chats').insert({
      'booking_id': bookingId,
      'customer_id': customerId,
      'seller_id': sellerId,
    }).select('id').single();
    return result['id'] as String;
  }

  List<BookingModel> _mapBookings(List data) {
    return data.map((e) {
      final map = Map<String, dynamic>.from(e);
      map['service_title'] = map['services']?['title'];
      map['seller_name'] = map['sellers']?['business_name'];
      return BookingModel.fromJson(map);
    }).toList();
  }
}

extension BookingModelX on BookingModel {
  BookingModel copyWith({String? chatRoomId, BookingStatus? status}) {
    return BookingModel(
      id: id,
      customerId: customerId,
      sellerId: sellerId,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      sellerName: sellerName,
      eventDate: eventDate,
      eventLocation: eventLocation,
      notes: notes,
      totalAmount: totalAmount,
      advanceAmount: advanceAmount,
      paidAmount: paidAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepositoryImpl(ref.watch(supabaseClientProvider)),
);
