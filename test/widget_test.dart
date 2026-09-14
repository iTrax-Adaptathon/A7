import 'package:adaptathon/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdaptiveApp initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveApp());
    expect(find.text('ADAPTIVE'), findsWidgets);
  });
}
