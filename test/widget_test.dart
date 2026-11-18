import 'package:flutter_test/flutter_test.dart';

import 'package:techfix/main.dart';

void main() {
  testWidgets('App displays the connected status', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TechFix - Firebase connected'), findsOneWidget);
  });
}
