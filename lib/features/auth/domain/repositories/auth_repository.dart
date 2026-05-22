import '../../../../shared/models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> get authStateChanges;
  UserProfile? get currentUser;
  bool get isAuthenticated;

  Future<UserProfile> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password, String fullName);
  Future<void> signInWithGoogle();
  Future<void> sendPhoneOtp(String phone);
  Future<UserProfile> verifyPhoneOtp(String phone, String otp);
  Future<void> signOut();
  Future<UserProfile> updateRole(String userId, String role);
  Future<UserProfile?> fetchProfile(String userId);
}
