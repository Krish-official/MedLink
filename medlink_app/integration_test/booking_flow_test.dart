import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medcare_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Flow Integration Test', () {
    testWidgets('Complete booking flow from login to confirmation',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Login
      await tester.enterText(find.byType(TextFormField).first, 'patient@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should navigate to dashboard
      expect(find.text('Welcome back,'), findsOneWidget);

      // Step 2: Navigate to booking
      await tester.tap(find.text('Book Appointment'));
      await tester.pumpAndSettle();

      // Should show doctor search
      expect(find.byType(TextField), findsOneWidget);

      // Step 3: Select a doctor
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Should show slot picker
      expect(find.text('Select Time Slot'), findsOneWidget);

      // Step 4: Select a date and time slot
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Should show confirmation screen
      expect(find.text('Confirm Booking'), findsOneWidget);

      // Step 5: Confirm booking
      await tester.tap(find.text('Confirm Booking'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show success screen
      expect(find.text('Booking Confirmed!'), findsOneWidget);
    });
  });
}