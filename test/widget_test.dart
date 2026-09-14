import 'package:adaptathon/main.dart';
import 'package:adaptathon/features/provider/adaptive_app_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('AdaptiveApp initializes smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AdaptiveAppProvider(),
        child: const AdaptiveApp(),
      ),
    );
    expect(find.text('ADAPTIVE'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    expect(find.text('Set Up Your Profile'), findsOneWidget);
  });
}
