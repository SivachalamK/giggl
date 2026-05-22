import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'payment_service_base.dart';

class PaymentService extends PaymentServiceBase {
  PaymentService(super.client);

  @override
  bool get isSupported => false;

  @override
  void init({
    required void Function(PaymentResult) onSuccess,
    required void Function(String) onError,
  }) {
    onSuccessCallback = onSuccess;
    onErrorCallback = onError;
  }

  @override
  void dispose() {}

  @override
  Future<void> payAdvance({
    required String bookingId,
    required double amount,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    onErrorCallback?.call(
      'Payments on web are coming soon. Please use the Android or iOS app.',
    );
  }
}

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(ref.watch(supabaseClientProvider)),
);
