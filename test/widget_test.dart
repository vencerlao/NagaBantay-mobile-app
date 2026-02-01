import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nagabantay_mobile_app/main.dart';

void main() {
  testWidgets('Nagabantay app loads without crashing', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Let splash animations / timers run
    await tester.pumpAndSettle();

    // Expect at least one Image (the app logo on splash or signup)
    expect(find.byType(Image), findsWidgets);
  });
}
