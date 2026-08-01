import 'package:flutter_test/flutter_test.dart';
import 'package:homehub_app/main.dart';

void main() {
  testWidgets('HomeHubApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HomeHubApp());
  });
}
