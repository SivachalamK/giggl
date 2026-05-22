import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/models/user_profile.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(supabaseClientProvider)),
);

class AuthState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => profile != null;

  AuthState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier(this._repo) : super(const AsyncValue.data(AuthState())) {
    _init();
  }

  final AuthRepository _repo;

  Future<void> _init() async {
    try {
      final profile = _repo.currentUser;
      state = AsyncValue.data(AuthState(profile: profile));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? const AuthState(isLoading: true),
    );
    try {
      final profile = await _repo.signInWithEmail(email, password);
      state = AsyncValue.data(AuthState(profile: profile));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? const AuthState(isLoading: true),
    );
    try {
      await _repo.signUpWithEmail(email, password, fullName);
      final profile = await _repo.signInWithEmail(email, password);
      state = AsyncValue.data(AuthState(profile: profile));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? const AuthState(isLoading: true),
    );
    try {
      await _repo.signInWithGoogle();
      final profile = _repo.currentUser;
      state = AsyncValue.data(AuthState(profile: profile));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendPhoneOtp(String phone) async {
    await _repo.sendPhoneOtp(phone);
  }

  Future<void> verifyPhoneOtp(String phone, String otp) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? const AuthState(isLoading: true),
    );
    try {
      final profile = await _repo.verifyPhoneOtp(phone, otp);
      state = AsyncValue.data(AuthState(profile: profile));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setRole(String role) async {
    final userId = state.valueOrNull?.profile?.id;
    if (userId == null) return;
    final profile = await _repo.updateRole(userId, role);
    state = AsyncValue.data(AuthState(profile: profile));
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(AuthState());
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider)),
);

final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.profile;
});
