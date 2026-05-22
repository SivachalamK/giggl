import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppConstants.desktopBreakpoint) {
      return ScreenSize.desktop;
    }
    if (width >= AppConstants.tabletBreakpoint) {
      return ScreenSize.tablet;
    }
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  static double value(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    switch (of(context)) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  static int columns(BuildContext context) {
    switch (of(context)) {
      case ScreenSize.desktop:
        return 4;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.mobile:
        return 2;
    }
  }

  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value(context, mobile: 16, tablet: 24, desktop: 32),
    );
  }

  static double maxContentWidth(BuildContext context) {
    return value(context, mobile: double.infinity, tablet: 900, desktop: 1200);
  }
}

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    switch (Responsive.of(context)) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }
}

class ContentContainer extends StatelessWidget {
  const ContentContainer({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? Responsive.padding(context),
          child: child,
        ),
      ),
    );
  }
}
