import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_route_optimizer/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify the home screen is displayed
    expect(find.text('Delivery Route Optimizer'), findsOneWidget);
    expect(find.text('Scan Receipt'), findsOneWidget);
  });
}
