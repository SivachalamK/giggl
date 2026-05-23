import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/seller/presentation/screens/seller_approval_pending_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/booking_tracking_screen.dart';
import '../../features/booking/presentation/screens/checkout_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payment/presentation/screens/payment_screen.dart';
import '../../features/profile/presentation/screens/customer_profile_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/seller/presentation/screens/availability_calendar_screen.dart';
import '../../features/seller/presentation/screens/booking_management_screen.dart';
import '../../features/seller/presentation/screens/earnings_analytics_screen.dart';
import '../../features/seller/presentation/screens/seller_dashboard_screen.dart';
import '../../features/seller/presentation/screens/seller_registration_screen.dart';
import '../../features/seller/presentation/screens/service_form_screen.dart';
import '../../features/services/presentation/screens/seller_profile_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../constants/app_constants.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull?.isAuthenticated ?? false;
      final role = authState.valueOrNull?.profile?.role;
      final location = state.matchedLocation;

      final publicRoutes = [
        '/splash',
        '/welcome',
        '/onboarding',
        '/role-selection',
        '/login',
        '/otp',
        '/seller-pending',
      ];

      if (!isLoggedIn && !publicRoutes.contains(location)) {
        return '/splash';
      }

      if (isLoggedIn && publicRoutes.contains(location)) {
        return _homeForRole(role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/seller-pending',
        builder: (_, __) => const SellerApprovalPendingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, state) => LoginScreen(
          role: state.uri.queryParameters['role'] ?? 'customer',
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          phone: state.uri.queryParameters['phone'] ?? '',
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const ServicesScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/wishlist',
            builder: (_, __) => const WishlistScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const CustomerProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/services',
        builder: (_, state) => ServicesScreen(
          category: state.uri.queryParameters['category'],
        ),
      ),
      GoRoute(
        path: '/seller/:id',
        builder: (_, state) => SellerProfileScreen(
          sellerId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/booking/:serviceId',
        builder: (_, state) => BookingScreen(
          serviceId: state.pathParameters['serviceId']!,
        ),
      ),
      GoRoute(
        path: '/checkout/:bookingId',
        builder: (_, state) => CheckoutScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: '/payment/:bookingId',
        builder: (_, state) => PaymentScreen(
          bookingId: state.pathParameters['bookingId']!,
        ),
      ),
      GoRoute(
        path: '/booking-tracking/:id',
        builder: (_, state) => BookingTrackingScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (_, __) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:roomId',
        builder: (_, state) => ChatScreen(
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (_, __) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/seller-register',
        builder: (_, __) => const SellerRegistrationScreen(),
      ),
      GoRoute(
        path: '/seller-dashboard',
        builder: (_, __) => const SellerDashboardScreen(),
      ),
      GoRoute(
        path: '/seller/service/new',
        builder: (_, __) => const ServiceFormScreen(),
      ),
      GoRoute(
        path: '/seller/service/:id/edit',
        builder: (_, state) => ServiceFormScreen(
          serviceId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/seller/bookings',
        builder: (_, __) => const BookingManagementScreen(),
      ),
      GoRoute(
        path: '/seller/earnings',
        builder: (_, __) => const EarningsAnalyticsScreen(),
      ),
      GoRoute(
        path: '/seller/availability',
        builder: (_, __) => const AvailabilityCalendarScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (_, __) => const AdminDashboardScreen(),
      ),
    ],
  );
});

String _homeForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return '/admin';
    case UserRole.seller:
      return '/seller-dashboard';
    default:
      return '/home';
  }
}
