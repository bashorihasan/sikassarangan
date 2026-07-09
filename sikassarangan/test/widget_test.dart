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
  testWidgets('siKasSarangan dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SiKasSaranganApp());

    await tester.pump();

    expect(find.text('Selamat datang,'), findsOneWidget);
    expect(find.text('Bendahara RT'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}
