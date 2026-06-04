// This is a basic Flutter widget test for AVM Global Consultants.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter_test/flutter_test.dart';
import 'package:avm_global_web/main.dart';

void main() {
  testWidgets('AVM Global App logo text smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AVMGlobalApp());

    // Verify that the company branding is present.
    expect(find.text('AVM GLOBAL'), findsWidgets);
    expect(find.text('CONSULTANTS'), findsWidgets);
  });
}
