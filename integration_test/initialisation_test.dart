import 'package:flutter/material.dart';
import 'package:flutter_app_template/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'integration_test_utils.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App initialisation tests', () {
    testWidgets('Initial screen snapshot', (t) async {
      runApp(const App());
      await t.pumpAndSettle(const Duration(seconds: 5));

      await takeScreenshot(t, binding, 'initial-screen');

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
