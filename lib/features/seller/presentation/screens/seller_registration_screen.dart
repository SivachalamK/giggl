import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SellerRegistrationScreen extends ConsumerStatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  ConsumerState<SellerRegistrationScreen> createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState
    extends ConsumerState<SellerRegistrationScreen> {
  final _businessController = TextEditingController();
  final _aadhaarController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      await client.from('sellers').upsert({
        'user_id': user.id,
        'business_name': _businessController.text,
        'aadhaar_number': _aadhaarController.text,
        'phone_verified': user.phone != null,
        'email_verified': user.email != null,
        'status': 'pending',
      });

      await client.from('seller_verification').insert({
        'seller_id': user.id,
        'aadhaar_number': _aadhaarController.text,
        'status': 'pending',
      });

      await ref.read(authStateProvider.notifier).setRole('seller');

      if (mounted) {
        context.showSnack('Registration submitted for approval');
        context.go('/seller-dashboard');
      }
    } catch (e) {
      if (mounted) context.showSnack(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadAadhaar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    // Upload to Supabase storage in production
    if (mounted) context.showSnack('Document selected: ${file.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Registration')),
      body: ContentContainer(
        child: ListView(
          children: [
            const Text(
              'Complete your seller profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _businessController,
              label: 'Business Name',
              hint: 'Your business name',
              prefixIcon: Icons.store,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _aadhaarController,
              label: 'Aadhaar Number',
              hint: 'XXXX XXXX XXXX',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _uploadAadhaar,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Aadhaar Document'),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Submit for Verification',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
