import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giggl/app.dart';

void main() {
  testWidgets('GigglApp builds', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GigglApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
