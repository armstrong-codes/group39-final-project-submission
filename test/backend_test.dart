import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group39_final_project_submission/data/demo_backend.dart';
import 'package:group39_final_project_submission/models/app_models.dart';

void main() {
  group('Firebase document models', () {
    test('school documents map every supported field', () {
      final school = SchoolModel.fromMap('school-1', {
        'name': 'Elimu Academy',
        'location': 'Kigali',
        'sector': 'Private',
        'level': 'Secondary',
        'educationStages': ['Primary', 'Secondary'],
        'availableSpots': 17,
        'availableSpotsLevel': 'Secondary',
        'availableSpotsClass': 'S4',
        'schoolFees': 850000,
        'email': 'school@example.com',
        'phone': '+250700000000',
        'imageUrls': ['https://example.com/school.png'],
        'ownerId': 'admin-1',
        'isActive': true,
      });

      expect(school.id, 'school-1');
      expect(school.educationStages, ['Primary', 'Secondary']);
      expect(school.availableSpots, 17);
      expect(school.formattedFees, '850,000 rfw');
      expect(school.imageUrls, hasLength(1));
    });

    test('application documents preserve the student review snapshot', () {
      final birthDate = DateTime(2009, 4, 21);
      final application = ApplicationModel.fromMap('application-1', {
        'studentId': 'student-1',
        'studentName': 'Aline Uwera',
        'studentEmail': 'aline@example.com',
        'studentPhone': '+250788000000',
        'studentLocation': 'Kacyiru',
        'studentGender': 'Female',
        'studentDateOfBirth': Timestamp.fromDate(birthDate),
        'educationLevel': 'Senior 3',
        'currentSchool': 'Kigali School',
        'schoolId': 'school-1',
        'schoolName': 'Elimu Academy',
        'transcriptUrl': 'https://example.com/transcript.pdf',
        'status': 'onHold',
        'createdAt': Timestamp.fromDate(DateTime(2026, 7, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 7, 2)),
      });

      expect(application.studentPhone, '+250788000000');
      expect(application.studentLocation, 'Kacyiru');
      expect(application.studentDateOfBirth, birthDate);
      expect(application.status, ApplicationStatus.onHold);
      expect(application.transcriptUrl, endsWith('.pdf'));
    });

    test('announcement and favorite documents match the ERD', () {
      final now = DateTime(2026, 7, 31);
      final announcement = AnnouncementModel.fromMap('notice-1', {
        'schoolId': 'school-1',
        'title': 'Admissions open',
        'body': 'Applications are now accepted.',
        'postedAt': Timestamp.fromDate(now),
        'postedBy': 'admin-1',
      });
      final favorite = FavoriteModel.fromMap('student-1_school-1', {
        'userId': 'student-1',
        'schoolId': 'school-1',
        'addedAt': Timestamp.fromDate(now),
      });

      expect(announcement.schoolId, 'school-1');
      expect(announcement.postedBy, 'admin-1');
      expect(favorite.userId, 'student-1');
      expect(favorite.schoolId, 'school-1');
    });
  });

  test('student submission and school review complete end to end', () async {
    final backend = DemoElimuBackend();
    final student = await backend.signIn(
      email: 'student@elimupath.rw',
      password: 'password',
    );
    expect(student.role, UserRole.student);

    final school = (await backend.watchSchools().first).first;
    final favoritesBefore = await backend.watchFavoriteSchoolIds().first;
    await backend.toggleFavorite(school.id);
    final favoritesAfter = await backend.watchFavoriteSchoolIds().first;
    expect(
      favoritesAfter.contains(school.id),
      !favoritesBefore.contains(school.id),
    );

    await backend.submitApplication(
      ApplicationDraft(
        schoolId: school.id,
        names: student.displayName,
        email: student.email,
        educationLevel: student.educationLevel,
        currentSchool: student.currentSchool,
      ),
    );
    final studentApplications = await backend.watchMyApplications().first;
    final submitted = studentApplications.first;
    expect(submitted.schoolId, school.id);
    expect(submitted.status, ApplicationStatus.pending);

    await backend.signOut();
    final admin = await backend.signIn(
      email: 'admin@elimupath.rw',
      password: 'password',
    );
    expect(admin.role, UserRole.schoolAdmin);
    final schoolApplications = await backend.watchSchoolApplications().first;
    expect(
      schoolApplications.map((application) => application.id),
      contains(submitted.id),
    );

    await backend.updateApplicationStatus(
      submitted.id,
      ApplicationStatus.approved,
    );
    final reviewed = await backend.watchApplication(submitted.id).first;
    expect(reviewed?.status, ApplicationStatus.approved);

    final stats = DashboardStats.fromApplications(
      await backend.watchSchoolApplications().first,
    );
    expect(stats.total, greaterThanOrEqualTo(1));
    expect(stats.approved, greaterThanOrEqualTo(1));
  });
}
