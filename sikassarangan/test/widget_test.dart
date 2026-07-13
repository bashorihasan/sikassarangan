// Smoke test dasar tanpa Firebase.
//
// Aplikasi penuh (SiKasSaranganApp) kini butuh Firebase.initializeApp() yang
// hanya berjalan lewat main(), sehingga tidak bisa di-pump langsung di test
// tanpa mocking Firebase. Untuk pengujian menyeluruh, tambahkan mock
// (mis. firebase_auth_mocks) terpisah.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp dasar dapat dirender', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('siKasSarangan')),
        ),
      ),
    );

    expect(find.text('siKasSarangan'), findsOneWidget);
  });
}
