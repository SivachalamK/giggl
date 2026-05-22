import 'package:flutter_test/flutter_test.dart';
import 'package:giggl/core/constants/app_constants.dart';
import 'package:giggl/shared/models/user_profile.dart';

void main() {
  group('UserRole', () {
    test('fromString parses seller', () {
      expect(UserRoleX.fromString('seller'), UserRole.seller);
    });

    test('fromString defaults to customer', () {
      expect(UserRoleX.fromString(null), UserRole.customer);
    });
  });

  group('UserProfile', () {
    test('fromJson parses correctly', () {
      final profile = UserProfile.fromJson({
        'id': '123',
        'email': 'test@test.com',
        'full_name': 'Test User',
        'role': 'customer',
      });

      expect(profile.id, '123');
      expect(profile.email, 'test@test.com');
      expect(profile.fullName, 'Test User');
      expect(profile.role, UserRole.customer);
    });
  });

  group('AppConstants', () {
    test('advance payment is 25%', () {
      expect(AppConstants.advancePaymentPercent, 0.25);
    });

    test('has all service categories', () {
      expect(AppConstants.serviceCategories.length, 15);
    });
  });
}
