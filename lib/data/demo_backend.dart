import 'dart:async';

import '../models/app_models.dart';
import 'elimu_backend.dart';

class DemoElimuBackend implements ElimuBackend {
  DemoElimuBackend() {
    _schools = [
      const SchoolModel(
        id: 'green-hills-academy',
        name: 'Green hills academy',
        location: 'Kibagabaga',
        sector: 'Private school',
        level: 'Secondary level',
        educationStages: ['Nursery', 'Primary', 'Secondary', 'Cambridge'],
        availableSpots: 12,
        availableSpotsLevel: 'Primary',
        availableSpotsClass: 'P3',
        schoolFees: 700000,
        email: 'schemail@gmail.com',
        phone: '(+250) 789-987-654',
        imageUrls: [],
        ownerId: 'demo-admin',
        isActive: true,
      ),
      const SchoolModel(
        id: 'blue-lakes-academy',
        name: 'Blue lakes academy',
        location: 'Kacyiru',
        sector: 'Private school',
        level: 'Primary level',
        educationStages: ['Nursery', 'Primary'],
        availableSpots: 8,
        availableSpotsLevel: 'Primary',
        availableSpotsClass: 'P5',
        schoolFees: 550000,
        email: 'hello@bluelakes.rw',
        phone: '(+250) 788-123-456',
        imageUrls: [],
        ownerId: 'demo-blue-admin',
        isActive: true,
      ),
      const SchoolModel(
        id: 'riverview-school',
        name: 'Riverview school',
        location: 'Nyarutarama',
        sector: 'Public school',
        level: 'Secondary level',
        educationStages: ['Secondary'],
        availableSpots: 21,
        availableSpotsLevel: 'Secondary',
        availableSpotsClass: 'S2',
        schoolFees: 250000,
        email: 'hello@riverview.rw',
        phone: '(+250) 788-222-333',
        imageUrls: [],
        ownerId: 'demo-river-admin',
        isActive: true,
      ),
      const SchoolModel(
        id: 'sunrise-academy',
        name: 'Sunrise academy',
        location: 'Kicukiro',
        sector: 'Private school',
        level: 'Secondary level',
        educationStages: ['Primary', 'Secondary'],
        availableSpots: 16,
        availableSpotsLevel: 'Secondary',
        availableSpotsClass: 'S1',
        schoolFees: 620000,
        email: 'hello@sunrise.rw',
        phone: '(+250) 788-444-555',
        imageUrls: [],
        ownerId: 'demo-sunrise-admin',
        isActive: true,
      ),
    ];
    _applications = [
      ApplicationModel(
        id: 'demo-application-1',
        studentId: 'demo-student',
        studentName: 'Demo Student',
        studentEmail: 'student@elimupath.rw',
        educationLevel: 'Senior 3',
        currentSchool: 'Blue lakes academy',
        schoolId: 'green-hills-academy',
        schoolName: 'Green hills academy',
        status: ApplicationStatus.pending,
        createdAt: DateTime(2026, 2, 12),
        updatedAt: DateTime(2026, 2, 12),
      ),
      ApplicationModel(
        id: 'demo-application-2',
        studentId: 'demo-student',
        studentName: 'Demo Student',
        studentEmail: 'student@elimupath.rw',
        educationLevel: 'Senior 3',
        currentSchool: 'Blue lakes academy',
        schoolId: 'blue-lakes-academy',
        schoolName: 'Blue lakes academy',
        status: ApplicationStatus.approved,
        createdAt: DateTime(2026, 2, 10),
        updatedAt: DateTime(2026, 2, 12),
      ),
    ];
  }

  final _profileController = StreamController<AppUserProfile?>.broadcast();
  final _schoolController = StreamController<List<SchoolModel>>.broadcast();
  final _applicationController =
      StreamController<List<ApplicationModel>>.broadcast();
  final _favoriteController = StreamController<Set<String>>.broadcast();

  late List<SchoolModel> _schools;
  late List<ApplicationModel> _applications;
  final Set<String> _favorites = {'blue-lakes-academy'};
  AppUserProfile? _profile;

  @override
  AppUserProfile? get cachedProfile => _profile;

  @override
  bool get isAuthenticated => _profile != null;

  AppUserProfile _studentProfile({String email = 'student@elimupath.rw'}) {
    return AppUserProfile(
      id: 'demo-student',
      role: UserRole.student,
      email: email,
      firstName: 'Demo',
      lastName: 'Student',
      username: 'student',
      phone: '(+250) 789-987-099',
      location: 'Kacyiru',
      gender: 'Male',
      educationLevel: 'Senior 3',
      currentSchool: 'Blue lakes academy',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  AppUserProfile get _adminProfile => AppUserProfile(
    id: 'demo-admin',
    role: UserRole.schoolAdmin,
    email: 'admin@elimupath.rw',
    firstName: 'Green hills',
    lastName: 'Academy',
    username: 'greenhills',
    phone: '(+250) 789-987-654',
    location: 'Kibagabaga',
    gender: '',
    educationLevel: '',
    currentSchool: '',
    schoolId: 'green-hills-academy',
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<AppUserProfile?> loadCurrentProfile() async => _profile;

  @override
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    _profile = email.toLowerCase().contains('admin')
        ? _adminProfile
        : _studentProfile(email: email);
    _profileController.add(_profile);
    return _profile!;
  }

  @override
  Future<AppUserProfile> registerStudent(
    StudentRegistration registration,
  ) async {
    _profile = AppUserProfile(
      id: 'demo-student',
      role: UserRole.student,
      email: registration.email,
      firstName: registration.firstName,
      lastName: registration.lastName,
      username: registration.username,
      phone: registration.phone,
      location: registration.location,
      gender: registration.gender,
      educationLevel: registration.educationLevel,
      currentSchool: registration.currentSchool,
      dateOfBirth: registration.dateOfBirth,
      createdAt: DateTime.now(),
    );
    _profileController.add(_profile);
    return _profile!;
  }

  @override
  Future<AppUserProfile> registerSchoolAdmin(
    SchoolAdminRegistration registration,
  ) async {
    _profile = AppUserProfile(
      id: 'demo-school-admin',
      role: UserRole.schoolAdmin,
      email: registration.email,
      firstName: '',
      lastName: '',
      username: registration.username,
      phone: registration.phone,
      location: registration.district,
      gender: '',
      educationLevel: '',
      currentSchool: registration.schoolName,
      schoolId: 'blue-lakes-academy',
      createdAt: DateTime.now(),
    );
    _profileController.add(_profile);
    return _profile!;
  }

  @override
  Future<void> signOut() async {
    _profile = null;
    _profileController.add(null);
  }

  @override
  Stream<AppUserProfile?> watchCurrentProfile() async* {
    yield _profile;
    yield* _profileController.stream;
  }

  @override
  Stream<List<SchoolModel>> watchSchools() async* {
    yield List.unmodifiable(_schools);
    yield* _schoolController.stream;
  }

  @override
  Stream<SchoolModel?> watchSchool(String schoolId) async* {
    SchoolModel? findSchool(List<SchoolModel> schools) {
      for (final school in schools) {
        if (school.id == schoolId) return school;
      }
      return null;
    }

    yield findSchool(_schools);
    await for (final schools in _schoolController.stream) {
      yield findSchool(schools);
    }
  }

  @override
  Stream<SchoolModel?> watchCurrentSchool() {
    final schoolId = _profile?.schoolId ?? 'green-hills-academy';
    return watchSchool(schoolId);
  }

  @override
  Stream<List<ApplicationModel>> watchMyApplications() async* {
    List<ApplicationModel> own(List<ApplicationModel> applications) {
      final userId = _profile?.id ?? 'demo-student';
      return applications
          .where((application) => application.studentId == userId)
          .toList(growable: false);
    }

    yield own(_applications);
    await for (final applications in _applicationController.stream) {
      yield own(applications);
    }
  }

  @override
  Stream<List<ApplicationModel>> watchSchoolApplications() async* {
    List<ApplicationModel> schoolApplications(
      List<ApplicationModel> applications,
    ) {
      final schoolId = _profile?.schoolId ?? 'green-hills-academy';
      return applications
          .where((application) => application.schoolId == schoolId)
          .toList(growable: false);
    }

    yield schoolApplications(_applications);
    await for (final applications in _applicationController.stream) {
      yield schoolApplications(applications);
    }
  }

  @override
  Stream<ApplicationModel?> watchApplication(String applicationId) async* {
    ApplicationModel? findApplication(List<ApplicationModel> applications) {
      for (final application in applications) {
        if (application.id == applicationId) return application;
      }
      return applications.isEmpty ? null : applications.first;
    }

    yield findApplication(_applications);
    await for (final applications in _applicationController.stream) {
      yield findApplication(applications);
    }
  }

  @override
  Stream<Set<String>> watchFavoriteSchoolIds() async* {
    yield Set.unmodifiable(_favorites);
    yield* _favoriteController.stream;
  }

  @override
  Future<void> toggleFavorite(String schoolId) async {
    if (!_favorites.remove(schoolId)) _favorites.add(schoolId);
    _favoriteController.add(Set.unmodifiable(_favorites));
  }

  @override
  Future<bool> submitApplication(ApplicationDraft draft) async {
    final profile = _profile ?? _studentProfile();
    final school = _schools.firstWhere(
      (item) => item.id == draft.schoolId,
      orElse: () => _schools.first,
    );
    _applications = [
      ApplicationModel(
        id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
        studentId: profile.id,
        studentName: draft.names,
        studentEmail: draft.email,
        educationLevel: draft.educationLevel,
        currentSchool: draft.currentSchool,
        schoolId: school.id,
        schoolName: school.name,
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ..._applications,
    ];
    _applicationController.add(List.unmodifiable(_applications));
    return true;
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    _applications = _applications
        .map(
          (application) => application.id == applicationId
              ? application.copyWith(status: status)
              : application,
        )
        .toList(growable: false);
    _applicationController.add(List.unmodifiable(_applications));
  }

  @override
  Future<void> updateSchool(
    SchoolModel school, {
    String? username,
    String? newPassword,
  }) async {
    _schools = _schools
        .map((item) => item.id == school.id ? school : item)
        .toList(growable: false);
    _schoolController.add(List.unmodifiable(_schools));
  }

  @override
  Future<String> uploadSchoolImage(UploadData image) async {
    return '';
  }
}
