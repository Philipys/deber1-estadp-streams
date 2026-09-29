import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parte_a_contador/main.dart';

void main() {
  testWidgets('Smoke test inicial de la app Riverpod', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AppRiverpod(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Contador:'), findsOneWidget);
  });
}
