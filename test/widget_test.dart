import 'package:flutter_test/flutter_test.dart';

import 'package:finance_tracker/app/app.dart';

void main() {
  testWidgets('App renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());
    expect(find.byType(FinanceTrackerApp), findsOneWidget);
  });
}
