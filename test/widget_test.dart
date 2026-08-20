import 'package:flutter_test/flutter_test.dart';

import 'package:anet_merchants/main.dart';

void main() {
  testWidgets('App shows splash while checking login session',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Loading...'), findsOneWidget);
  });
}
