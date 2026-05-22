import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giggl/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows app name', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SplashScreen()),
      ),
    );

    expect(find.text('Giggl'), findsOneWidget);
    expect(find.text('Events made effortless'), findsOneWidget);
  });
}
