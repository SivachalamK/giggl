import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.selectedIndex = 0,
    this.onNavTap,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final int selectedIndex;
  final void Function(int)? onNavTap;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              selectedIndex: selectedIndex,
              onDestinationSelected: onNavTap,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  if (title != null)
                    AppBar(title: Text(title!), actions: actions),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!), actions: actions) : null,
      body: body,
    );
  }
}
