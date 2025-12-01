import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart'; // Sesuaikan dengan nama package Anda

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BelajarTaniApp());

    // Verify that our app is running
    expect(find.text('BelajarTani'), findsOneWidget);
    
    // Depending on your app, you can add more tests
    // Contoh: cari tombol Daftar atau Masuk
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}