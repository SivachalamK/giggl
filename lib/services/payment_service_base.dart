import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';

class PaymentResult {
  final String paymentId;
  final String orderId;
  final String signature;

  PaymentResult({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
}

abstract class PaymentServiceBase {
  PaymentServiceBase(this._client);

  final SupabaseClient _client;
  void Function(PaymentResult)? onSuccessCallback;
  void Function(String)? onErrorCallback;

  bool get isSupported;

  void init({
    required void Function(PaymentResult) onSuccess,
    required void Function(String) onError,
  });

  void dispose();

  Future<void> payAdvance({
    required String bookingId,
    required double amount,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  });

  Future<void> recordPayment({
    required String bookingId,
    required String userId,
    required double amount,
    required String razorpayPaymentId,
    required String status,
    String type = 'advance',
  }) async {
    await _client.from('payments').insert({
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'razorpay_payment_id': razorpayPaymentId,
      'status': status,
      'type': type,
      'currency': AppConstants.currency,
    });
  }

  Future<void> processRefund({
    required String paymentId,
    required double amount,
  }) async {
    await _client.from('payments').update({
      'status': 'refunded',
      'refund_amount': amount,
      'refunded_at': DateTime.now().toIso8601String(),
    }).eq('razorpay_payment_id', paymentId);
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    final data = await _client
        .from('payments')
        .select('*, bookings(service_id, services(title))')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}
