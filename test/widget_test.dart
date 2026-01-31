// Basic Flutter widget test for Sant Narhari Sonar app.

import 'package:flutter_test/flutter_test.dart';

import 'package:sant_narhari_sonar/main.dart';

void main() {
  testWidgets('App loads and shows title', (WidgetTester tester) async {
    await tester.pumpWidget(const SantNarhariSonarApp());

    expect(find.text('Sant Narhari Sonar'), findsWidgets);
  });
}
