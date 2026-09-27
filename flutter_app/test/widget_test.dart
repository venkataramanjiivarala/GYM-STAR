import 'package:flutter_test/flutter_test.dart';
import 'package:gymstar_mobile/main.dart';

void main() {
  testWidgets('GYM STAR app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GymStarApp());

    // Verify that the title is present.
    expect(find.textContaining('GYM STAR'), findsWidgets);
  });
}
