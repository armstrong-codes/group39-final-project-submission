import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_routes.dart';
import '../app_theme.dart';
import '../data/app_services.dart';
import '../models/app_models.dart';
import '../widgets/common.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 1700),
      () => unawaited(_openNextPage()),
    );
  }

  Future<void> _openNextPage() async {
    AppUserProfile? profile;
    try {
      profile = await AppServices.backend.loadCurrentProfile();
    } catch (_) {
      profile = null;
    }
    if (!mounted) return;
    final route = switch (profile?.role) {
      UserRole.schoolAdmin => AppRoutes.adminDashboard,
      UserRole.student => AppRoutes.forYou,
      null => AppRoutes.signIn,
    };
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.nav,
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(size: 116, variant: BrandLogoVariant.gradient),
              SizedBox(height: 24),
              Text(
                'ELIMUPATH',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final profile = await AppServices.backend.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        profile.role == UserRole.schoolAdmin
            ? AppRoutes.adminDashboard
            : AppRoutes.forYou,
        (_) => false,
      );
    } catch (error) {
      if (mounted) showElimuMessage(context, firebaseMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthTopBar(onArrowTap: _submit),
            const SizedBox(height: 42),
            const Text(
              'Sign in',
              style: TextStyle(
                fontSize: 50,
                height: 0.95,
                fontWeight: FontWeight.w200,
                letterSpacing: -2.2,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Fill in your credential to access your dashboard.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 46),
            ElimuTextField(
              label: 'Email',
              controller: _emailController,
              validator: emailField,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 22),
            ElimuTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: requiredField,
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(height: 35),
            PrimaryButton(
              label: _isSubmitting ? 'Signing in...' : 'Send',
              onPressed: _submit,
            ),
            const SizedBox(height: 13),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    "I don't have an account! ",
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.signUp,
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 190),
          ],
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _currentSchoolController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _districtController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _photoController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _educationLevel;
  String _accountType = 'Student';
  UploadData? _photo;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _currentSchoolController.dispose();
    _schoolNameController.dispose();
    _districtController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(1980),
      lastDate: now,
      initialDate: DateTime(now.year - 15),
    );
    if (selected != null) {
      _dateOfBirth = selected;
      _dateController.text =
          '${selected.day.toString().padLeft(2, '0')}/${selected.month.toString().padLeft(2, '0')}/${selected.year}';
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _photo = UploadData(
        bytes: bytes,
        fileName: picked.name,
        contentType: picked.mimeType,
      );
      _photoController.text = picked.name;
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    if (_accountType == 'Student' && _dateOfBirth == null) {
      showElimuMessage(context, 'Choose your date of birth.');
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      if (_accountType == 'School') {
        await AppServices.backend.registerSchoolAdmin(
          SchoolAdminRegistration(
            schoolName: _schoolNameController.text,
            district: _districtController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            username: _usernameController.text,
            password: _passwordController.text,
          ),
        );
      } else {
        await AppServices.backend.registerStudent(
          StudentRegistration(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            gender: _gender!,
            dateOfBirth: _dateOfBirth!,
            educationLevel: _educationLevel!,
            currentSchool: _currentSchoolController.text,
            location: _locationController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            username: _usernameController.text,
            password: _passwordController.text,
            photo: _photo,
          ),
        );
      }
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        _accountType == 'School'
            ? AppRoutes.adminDashboard
            : AppRoutes.forYou,
        (_) => false,
      );
    } catch (error) {
      if (mounted) showElimuMessage(context, firebaseMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElimuPage(
      bottomNavigation: const ElimuBottomNavigation(currentIndex: 0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AuthTopBar(
              onArrowTap: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.signIn),
            ),
            const SizedBox(height: 34),
            const Text(
              'Sign up',
              style: TextStyle(
                fontSize: 50,
                height: 0.95,
                fontWeight: FontWeight.w200,
                letterSpacing: -2.2,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Create your account to use this app efficiently.',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 34),
            ElimuDropdownField(
              label: 'Account type',
              value: _accountType,
              items: const ['Student', 'School'],
              onChanged: (value) {
                if (value != null) setState(() => _accountType = value);
              },
            ),
            const SizedBox(height: 20),
            if (_accountType == 'Student') ...[
              _TwoFields(
              left: ElimuTextField(
                label: 'First name',
                controller: _firstNameController,
                validator: requiredField,
              ),
              right: ElimuTextField(
                label: 'Last name',
                controller: _lastNameController,
                validator: requiredField,
              ),
            ),
            const SizedBox(height: 20),
            _TwoFields(
              left: ElimuDropdownField(
                label: 'Choose gender',
                value: _gender,
                items: const ['Female', 'Male', 'Other'],
                onChanged: (value) => setState(() => _gender = value),
              ),
              right: ElimuTextField(
                label: 'Date of birth',
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                validator: requiredField,
              ),
            ),
            const SizedBox(height: 20),
            _TwoFields(
              left: ElimuDropdownField(
                label: 'Education level',
                value: _educationLevel,
                items: const [
                  'Senior 1',
                  'Senior 2',
                  'Senior 3',
                  'Senior 4',
                  'Senior 5',
                  'Senior 6',
                ],
                onChanged: (value) =>
                    setState(() => _educationLevel = value),
              ),
              right: ElimuTextField(
                label: 'Location',
                controller: _locationController,
                validator: requiredField,
              ),
            ),
              const SizedBox(height: 20),
              ElimuTextField(
              label: 'Current school',
              controller: _currentSchoolController,
              validator: requiredField,
              ),
            ] else ...[
              _TwoFields(
                left: ElimuTextField(
                  label: 'School name',
                  controller: _schoolNameController,
                  validator: requiredField,
                ),
                right: ElimuTextField(
                  label: 'District',
                  controller: _districtController,
                  validator: requiredField,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _TwoFields(
              left: ElimuTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: emailField,
              ),
              right: ElimuTextField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: requiredField,
              ),
            ),
            const SizedBox(height: 20),
            _TwoFields(
              left: ElimuTextField(
                label: 'Username',
                controller: _usernameController,
                validator: requiredField,
              ),
              right: ElimuTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                validator: passwordField,
              ),
            ),
            if (_accountType == 'Student') ...[
              const SizedBox(height: 20),
              ElimuTextField(
                label: 'Upload your picture',
                controller: _photoController,
                readOnly: true,
                onTap: _pickPhoto,
                suffixIcon: const Icon(Icons.upload_file_outlined, size: 20),
              ),
            ],
            const SizedBox(height: 28),
            PrimaryButton(
              label: _isSubmitting ? 'Creating account...' : 'Send',
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.signIn,
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTopBar extends StatelessWidget {
  const _AuthTopBar({required this.onArrowTap});

  final VoidCallback onArrowTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandLockup(compact: true),
        const Spacer(),
        CircleIconButton(icon: Icons.arrow_forward_rounded, onTap: onArrowTap),
      ],
    );
  }
}

class _TwoFields extends StatelessWidget {
  const _TwoFields({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    );
  }
}

String firebaseMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'The email or password is incorrect.',
      'email-already-in-use' => 'An account already uses this email.',
      'weak-password' => 'Use a password with at least 6 characters.',
      'network-request-failed' => 'Check your internet connection.',
      _ => error.message ?? 'Firebase could not complete the request.',
    };
  }
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' =>
        'Firebase permissions are not deployed for this project.',
      'unavailable' => 'Firebase is temporarily unavailable. Try again.',
      _ => error.message ?? 'Firebase could not complete the request.',
    };
  }
  if (error is TimeoutException) {
    return 'Firebase took too long to respond. Please try again.';
  }
  final message = error.toString();
  return message.startsWith('Exception: ')
      ? message.substring('Exception: '.length)
      : message;
}
