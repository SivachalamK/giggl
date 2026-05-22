class AppConstants {
  static const String appName = 'Giggl';
  static const String appTagline = 'Events made effortless';

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static const double defaultPadding = 16;
  static const double cardRadius = 20;
  static const double buttonRadius = 14;

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  static const double advancePaymentPercent = 0.25;
  static const String currency = 'INR';
  static const String currencySymbol = '₹';

  static const List<String> serviceCategories = [
    'Photography',
    'Videography',
    'Catering',
    'DJ',
    'Travels',
    'Makeup Artist',
    'Mehendi',
    'Astrologer',
    'Iyer/Priest',
    'Decoration',
    'Balloon Decoration',
    'Wedding Planner',
    'Stage Setup',
    'Sound System',
    'Return Gifts',
  ];

  static const Map<String, String> categoryIcons = {
    'Photography': '📷',
    'Videography': '🎬',
    'Catering': '🍽️',
    'DJ': '🎧',
    'Travels': '🚗',
    'Makeup Artist': '💄',
    'Mehendi': '🌿',
    'Astrologer': '⭐',
    'Iyer/Priest': '🙏',
    'Decoration': '🎨',
    'Balloon Decoration': '🎈',
    'Wedding Planner': '💒',
    'Stage Setup': '🎭',
    'Sound System': '🔊',
    'Return Gifts': '🎁',
  };
}

enum UserRole { customer, seller, admin }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'seller':
        return UserRole.seller;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  refunded,
}

enum PaymentStatus {
  pending,
  advancePaid,
  fullyPaid,
  failed,
  refunded,
}
