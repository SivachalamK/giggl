import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();

  Future<void> _verify() async {
    if (_otpController.text.length != AppConstants.otpLength) {
      context.showSnack('Enter ${AppConstants.otpLength} digit OTP', isError: true);
      return;
    }
    await ref.read(authStateProvider.notifier).verifyPhoneOtp(
          widget.phone,
          _otpController.text,
        );
    final state = ref.read(authStateProvider);
    if (state.hasError) {
      context.showSnack(state.error.toString(), isError: true);
      return;
    }
    if (mounted && (state.valueOrNull?.isAuthenticated ?? false)) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authStateProvider).valueOrNull?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: ContentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              'Enter the OTP sent to\n${widget.phone}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: AppConstants.otpLength,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                hintText: '• • • • • •',
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Verify & Continue',
              isLoading: isLoading,
              onPressed: _verify,
            ),
          ],
        ),
      ),
    );
  }
}
