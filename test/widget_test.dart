import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_mate/main.dart';

void main() {
  testWidgets(
    'PrepMate app starts successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PrepMateApp(),
        ),
      );

      await tester.pump();
    },
  );
}