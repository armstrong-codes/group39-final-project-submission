import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:group39_final_project_submission/app_theme.dart';
import 'package:group39_final_project_submission/main.dart';
import 'package:group39_final_project_submission/screens/admin_screens.dart';
import 'package:group39_final_project_submission/screens/auth_screens.dart';
import 'package:group39_final_project_submission/screens/student_screens.dart';

void main() {
  testWidgets('splash screen opens the sign-in page', (tester) async {
    await _usePhoneSurface(tester);
    await tester.pumpWidget(const ElimuPathApp());

    expect(find.text('ELIMUPATH'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('sign-in validates and opens the student home', (tester) async {
    await _usePhoneSurface(tester);
    await tester.pumpWidget(const ElimuPathApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('This field is required'), findsNWidgets(2));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'student@elimupath.rw');
    await tester.enterText(fields.at(1), 'password');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(find.text('For your page'), findsOneWidget);
  });

  testWidgets('school card opens details and application form', (tester) async {
    await _usePhoneSurface(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        routes: {
          '/': (_) => const ForYouPage(),
          '/school-details': (_) => const SchoolDetailsPage(),
          '/application-form': (_) => const ApplicationFormPage(),
          '/account': (_) => const MyAccountPage(),
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Green hills academy'));
    await tester.pumpAndSettle();
    expect(find.text('School details'), findsOneWidget);

    await tester.ensureVisible(find.text('Apply here!'));
    await tester.tap(find.text('Apply here!'));
    await tester.pumpAndSettle();
    expect(find.text('Applications form'), findsOneWidget);
  });

  testWidgets('all supplied design pages render without exceptions', (
    tester,
  ) async {
    final pages = <Widget>[
      const SignInPage(),
      const SignUpPage(),
      const ForYouPage(),
      const SchoolDetailsPage(),
      const ApplicationFormPage(),
      const ApplicationsPage(),
      const AdminDashboardPage(),
      const AllRequestsPage(),
      const RequestDetailsPage(),
      const MyAccountPage(),
      const EditAccountPage(),
    ];

    await _usePhoneSurface(tester);

    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: page));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${page.runtimeType}');
    }
  });
}

Future<void> _usePhoneSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}
