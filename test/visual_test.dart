import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:group39_final_project_submission/widgets/common.dart';

import 'package:group39_final_project_submission/app_theme.dart';
import 'package:group39_final_project_submission/screens/admin_screens.dart';
import 'package:group39_final_project_submission/screens/auth_screens.dart';
import 'package:group39_final_project_submission/screens/student_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final epilogueLoader = FontLoader('Epilogue')
      ..addFont(rootBundle.load('assets/fonts/Epilogue-Variable.ttf'));
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await Future.wait([epilogueLoader.load(), iconLoader.load()]);
  });

  final pages = <String, Widget>{
    'splash': const SplashPage(),
    'sign-in': const SignInPage(),
    'sign-up': const SignUpPage(),
    'for-you': const ForYouPage(),
    'school-details': const SchoolDetailsPage(),
    'application-form': const ApplicationFormPage(),
    'applications': const ApplicationsPage(),
    'admin-dashboard': const AdminDashboardPage(),
    'all-requests': const AllRequestsPage(),
    'request-details': const RequestDetailsPage(),
    'my-account': const MyAccountPage(),
    'edit-account': const EditAccountPage(),
  };

  for (final entry in pages.entries) {
    testWidgets('${entry.key} visual regression', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: RepaintBoundary(key: boundaryKey, child: entry.value),
        ),
      );
      final context = tester.element(find.byKey(boundaryKey));
      await tester.runAsync(() async {
        await Future.wait([
          precacheImage(
            const AssetImage('assets/images/brand-black.png'),
            context,
          ),
          precacheImage(
            const AssetImage('assets/images/brand-gradient.png'),
            context,
          ),
          precacheImage(
            const AssetImage('assets/images/brand-lime.png'),
            context,
          ),
          precacheImage(
            const AssetImage('assets/images/brand-teal.png'),
            context,
          ),
          precacheImage(
            const AssetImage('assets/images/brand-white.png'),
            context,
          ),
          precacheImage(const AssetImage('assets/images/school.png'), context),
          precacheImage(
            const AssetImage('assets/images/schools/school_01.jpg'),
            context,
          ),
        ]);
      });
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(boundaryKey),
        matchesGoldenFile('goldens/${entry.key}.png'),
      );
    });
  }
}
