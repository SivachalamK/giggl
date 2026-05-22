import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart' show AppConstants, BookingStatus, PaymentStatus;
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/payment_service.dart' show PaymentResult, paymentServiceProvider;
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../booking/data/repositories/booking_repository_impl.dart';
import '../../../booking/presentation/providers/booking_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPayment());
  }

  void _initPayment() {
    ref.read(paymentServiceProvider).init(
      onSuccess: _onPaymentSuccess,
      onError: (msg) {
        if (mounted) {
          setState(() => _isProcessing = false);
          context.showSnack(msg, isError: true);
        }
      },
    );
  }

  @override
  void dispose() {
    ref.read(paymentServiceProvider).dispose();
    super.dispose();
  }

  Future<void> _onPaymentSuccess(PaymentResult result) async {
    final booking = await ref.read(bookingDetailProvider(widget.bookingId).future);
    final user = ref.read(currentUserProvider);
    if (booking == null || user == null) return;

    final paymentService = ref.read(paymentServiceProvider);
    await paymentService.recordPayment(
      bookingId: widget.bookingId,
      userId: user.id,
      amount: booking.advanceAmount,
      razorpayPaymentId: result.paymentId,
      status: 'completed',
    );

    await ref.read(bookingRepositoryProvider).updatePayment(
          widget.bookingId,
          paidAmount: booking.advanceAmount,
          paymentStatus: PaymentStatus.advancePaid.name,
        );

    await ref.read(bookingRepositoryProvider).updateStatus(
          widget.bookingId,
          BookingStatus.confirmed.name,
        );

    if (mounted) {
      setState(() => _isProcessing = false);
      context.showSnack('Payment successful!');
      context.go('/booking-tracking/${widget.bookingId}');
    }
  }

  Future<void> _pay() async {
    final booking = await ref.read(bookingDetailProvider(widget.bookingId).future);
    final user = ref.read(currentUserProvider);
    if (booking == null || user == null) return;

    setState(() => _isProcessing = true);
    await ref.read(paymentServiceProvider).payAdvance(
          bookingId: widget.bookingId,
          amount: booking.advanceAmount,
          customerEmail: user.email ?? 'customer@giggl.app',
          customerPhone: user.phone ?? '9999999999',
          customerName: user.fullName ?? 'Customer',
        );
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) return const Center(child: Text('Not found'));
          return ContentContainer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, size: 80),
                const SizedBox(height: 24),
                Text(
                  'Pay advance of ${AppConstants.currencySymbol}${booking.advanceAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Secured by Razorpay',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 48),
                GradientButton(
                  label: 'Pay Now',
                  isLoading: _isProcessing,
                  onPressed: _pay,
                  icon: Icons.lock,
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
