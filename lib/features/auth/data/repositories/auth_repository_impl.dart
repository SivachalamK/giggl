import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../core/config/env_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../shared/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final supa.SupabaseClient _client;

  @override
  Stream<UserProfile?> get authStateChanges async* {
    yield currentUser;
    await for (final state in _client.auth.onAuthStateChange) {
      if (state.session?.user != null) {
        yield await fetchProfile(state.session!.user.id);
      } else {
        yield null;
      }
    }
  }

  @override
  UserProfile? get currentUser {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserProfile(
      id: user.id,
      email: user.email,
      phone: user.phone,
      fullName: user.userMetadata?['full_name'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      role: UserRoleX.fromString(user.userMetadata?['role'] as String?),
    );
  }

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  Future<UserProfile> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return await _profileFromUser(response.user!);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<void> signUpWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': UserRole.customer.value},
      );
    } on supa.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: EnvConfig.googleWebClientId.isNotEmpty
            ? EnvConfig.googleWebClientId
            : null,
      );
      final account = await googleSignIn.signIn();
      if (account == null) throw const AuthException('Google sign in cancelled');

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        throw const AuthException('No ID token from Google');
      }

      await _client.auth.signInWithIdToken(
        provider: supa.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserProfile> verifyPhoneOtp(String phone, String otp) async {
    try {
      final response = await _client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: supa.OtpType.sms,
      );
      return await _profileFromUser(response.user!);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<UserProfile> updateRole(String userId, String role) async {
    await _client.from('users').update({'role': role}).eq('id', userId);
    await _client.auth.updateUser(
      supa.UserAttributes(data: {'role': role}),
    );
    return (await fetchProfile(userId))!;
  }

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return currentUser;
      return UserProfile.fromJson(data);
    } catch (_) {
      return currentUser;
    }
  }

  Future<UserProfile> _profileFromUser(supa.User user) async {
    final profile = await fetchProfile(user.id);
    return profile ??
        UserProfile(
          id: user.id,
          email: user.email,
          phone: user.phone,
          fullName: user.userMetadata?['full_name'] as String?,
          role: UserRoleX.fromString(user.userMetadata?['role'] as String?),
        );
  }
}
