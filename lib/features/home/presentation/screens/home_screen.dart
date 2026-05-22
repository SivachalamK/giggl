import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return _DesktopShell(child: child);
    }
    return _MobileShell(child: child);
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/wishlist')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/search');
            case 2:
              context.go('/wishlist');
            case 3:
              context.go('/profile');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/notifications'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: colors.surface,
            selectedIndex: _railIndex(location),
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/home');
                case 1:
                  context.go('/search');
                case 2:
                  context.go('/wishlist');
                case 3:
                  context.go('/profile');
                case 4:
                  context.push('/notifications');
                case 5:
                  context.push('/chats');
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Search'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                label: Text('Wishlist'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                label: Text('Notifications'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_outlined),
                label: Text('Chats'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _railIndex(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/wishlist')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }
}
