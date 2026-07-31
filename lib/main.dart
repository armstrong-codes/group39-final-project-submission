import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_routes.dart';
import 'app_theme.dart';
import 'data/app_services.dart';
import 'data/firebase_backend.dart';
import 'firebase_options.dart';
import 'screens/admin_screens.dart';
import 'screens/auth_screens.dart';
import 'screens/student_screens.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Object? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppServices.configure(FirebaseElimuBackend());
  } catch (error) {
    startupError = error;
  }
  runApp(ElimuPathApp(startupError: startupError));
}

class ElimuPathApp extends StatelessWidget {
  const ElimuPathApp({this.startupError, super.key});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElimuPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: startupError == null ? AppRoutes.splash : null,
      home: startupError == null
          ? null
          : _FirebaseStartupError(error: startupError!),
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.signIn: (_) => const SignInPage(),
        AppRoutes.signUp: (_) => const SignUpPage(),
        AppRoutes.forYou: (_) => const ForYouPage(),
        AppRoutes.likedSchools: (_) => const LikedSchoolsPage(),
        AppRoutes.schoolDetails: (context) => SchoolDetailsPage(
          schoolId: ModalRoute.of(context)?.settings.arguments as String?,
        ),
        AppRoutes.applicationForm: (context) => ApplicationFormPage(
          schoolId: ModalRoute.of(context)?.settings.arguments as String?,
        ),
        AppRoutes.applications: (_) => const ApplicationsPage(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardPage(),
        AppRoutes.requests: (_) => const AllRequestsPage(),
        AppRoutes.requestDetails: (context) => RequestDetailsPage(
          applicationId: ModalRoute.of(context)?.settings.arguments as String?,
        ),
        AppRoutes.account: (_) => const MyAccountPage(),
        AppRoutes.editAccount: (_) => const EditAccountPage(),
      },
    );
  }
}

class _FirebaseStartupError extends StatelessWidget {
  const _FirebaseStartupError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BrandLockup(),
          const SizedBox(height: 36),
          const Icon(Icons.cloud_off_outlined, size: 54),
          const SizedBox(height: 18),
          const Text(
            'Firebase could not start',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 18),
          const Text(
            'Check the internet connection and restart the app.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Kept as a compatibility alias for starter-project imports.
typedef MyApp = ElimuPathApp;
