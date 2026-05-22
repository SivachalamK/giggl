import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/buttons/gradient_button.dart';
import '../../../../shared/widgets/buttons/outline_button_widget.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, required this.role});

  final String role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authStateProvider.notifier);
    if (_isSignUp) {
      await notifier.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    } else {
      await notifier.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
    await _afterAuth();
  }

  Future<void> _handleGoogle() async {
    await ref.read(authStateProvider.notifier).signInWithGoogle();
    await _afterAuth();
  }

  Future<void> _handlePhone() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      context.showSnack('Enter valid phone number', isError: true);
      return;
    }
    await ref.read(authStateProvider.notifier).sendPhoneOtp('+91$phone');
    if (mounted) context.push('/otp?phone=+91$phone');
  }

  Future<void> _afterAuth() async {
    final state = ref.read(authStateProvider);
    if (state.hasError) {
      context.showSnack(state.error.toString(), isError: true);
      return;
    }
    if (state.valueOrNull?.isAuthenticated ?? false) {
      await ref.read(authStateProvider.notifier).setRole(widget.role);
      if (!mounted) return;
      if (widget.role == 'seller') {
        context.go('/seller-register');
      } else if (widget.role == 'admin') {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isLoading = ref.watch(authStateProvider).valueOrNull?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-selection'),
        ),
        title: Text('${widget.role[0].toUpperCase()}${widget.role.substring(1)} Login'),
      ),
      body: ContentContainer(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: colors.primary,
              tabs: const [
                Tab(text: 'Email'),
                Tab(text: 'Phone'),
                Tab(text: 'Google'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmailTab(isLoading),
                  _buildPhoneTab(isLoading),
                  _buildGoogleTab(isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTab(bool isLoading) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          if (_isSignUp)
            AppTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              prefixIcon: Icons.person_outline,
            ),
          if (_isSignUp) const SizedBox(height: 16),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'you@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v != null && v.contains('@') ? null : 'Invalid email',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            validator: (v) =>
                v != null && v.length >= 6 ? null : 'Min 6 characters',
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: _isSignUp ? 'Sign Up' : 'Sign In',
            isLoading: isLoading,
            onPressed: _handleEmailAuth,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : 'New here? Create Account',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTab(bool isLoading) {
    return ListView(
      children: [
        AppTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '9876543210',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: 'Send OTP',
          isLoading: isLoading,
          onPressed: _handlePhone,
        ),
      ],
    );
  }

  Widget _buildGoogleTab(bool isLoading) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.g_mobiledata, size: 80),
        const SizedBox(height: 24),
        const Text(
          'Continue with your Google account',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlineButtonWidget(
          label: 'Sign in with Google',
          icon: Icons.login,
          onPressed: isLoading ? null : _handleGoogle,
        ),
      ],
    );
  }
}
