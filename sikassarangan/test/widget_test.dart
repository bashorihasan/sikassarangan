// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sikassarangan/main.dart';

void main() {
  testWidgets('siKasSarangan app renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiKasSaranganApp());

    await tester.pump();

    // Verify the main app shell appears.
    expect(find.text('siKasSarangan'), findsOneWidget);

    // Tap the refresh icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pump();
  });
}
