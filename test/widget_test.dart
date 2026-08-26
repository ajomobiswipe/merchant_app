import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anet_merchants/main.dart';

void main() {
  testWidgets('App root starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
