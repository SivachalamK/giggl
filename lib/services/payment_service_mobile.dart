import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../core/config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import 'payment_service_base.dart';

class PaymentService extends PaymentServiceBase {
  PaymentService(super.client);

  Razorpay? _razorpay;

  @override
  bool get isSupported => !kIsWeb;

  @override
  void init({
    required void Function(PaymentResult) onSuccess,
    required void Function(String) onError,
  }) {
    if (kIsWeb) return;
    onSuccessCallback = onSuccess;
    onErrorCallback = onError;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternal);
  }

  @override
  void dispose() {
    _razorpay?.clear();
  }

  @override
  Future<void> payAdvance({
    required String bookingId,
    required double amount,
    required String customerEmail,
    required String customerPhone,
    required String customerName,
  }) async {
    if (kIsWeb) {
      onErrorCallback?.call('Razorpay is not available on web.');
      return;
    }

    final options = {
      'key': EnvConfig.razorpayKeyId,
      'amount': (amount * 100).toInt(),
      'name': AppConstants.appName,
      'description': 'Advance payment for booking',
      'prefill': {
        'contact': customerPhone,
        'email': customerEmail,
        'name': customerName,
      },
      'notes': {'booking_id': bookingId},
      'theme': {'color': '#3B82F6'},
    };

    _razorpay?.open(options);
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    onSuccessCallback?.call(PaymentResult(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
    ));
  }

  void _handleError(PaymentFailureResponse response) {
    onErrorCallback?.call(response.message ?? 'Payment failed');
  }

  void _handleExternal(ExternalWalletResponse response) {
    onErrorCallback?.call('External wallet: ${response.walletName}');
  }
}

final paymentServiceProvider = Provider<PaymentService>(
  (ref) => PaymentService(ref.watch(supabaseClientProvider)),
);
