import '../models/app_models.dart';

abstract interface class ElimuBackend {
  AppUserProfile? get cachedProfile;
  bool get isAuthenticated;

  Future<AppUserProfile?> loadCurrentProfile();
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
  });
  Future<AppUserProfile> registerStudent(StudentRegistration registration);
  Future<AppUserProfile> registerSchoolAdmin(
    SchoolAdminRegistration registration,
  );
  Future<void> signOut();

  Stream<AppUserProfile?> watchCurrentProfile();
  Stream<List<SchoolModel>> watchSchools();
  Stream<SchoolModel?> watchSchool(String schoolId);
  Stream<SchoolModel?> watchCurrentSchool();
  Stream<List<ApplicationModel>> watchMyApplications();
  Stream<List<ApplicationModel>> watchSchoolApplications();
  Stream<ApplicationModel?> watchApplication(String applicationId);
  Stream<Set<String>> watchFavoriteSchoolIds();

  Future<void> toggleFavorite(String schoolId);
  Future<bool> submitApplication(ApplicationDraft draft);
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  );
  Future<void> updateSchool(
    SchoolModel school, {
    String? username,
    String? newPassword,
  });
  Future<String> uploadSchoolImage(UploadData image);
}
