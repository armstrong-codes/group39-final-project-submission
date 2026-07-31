import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_models.dart';
import 'elimu_backend.dart';

class FirebaseElimuBackend implements ElimuBackend {
  FirebaseElimuBackend({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AppUserProfile? _cachedProfile;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _schools =>
      _firestore.collection('schools');
  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');
  CollectionReference<Map<String, dynamic>> get _favorites =>
      _firestore.collection('favorites');

  @override
  AppUserProfile? get cachedProfile => _cachedProfile;

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  Future<AppUserProfile?> loadCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _cachedProfile = null;
      return null;
    }
    final snapshot = await _users.doc(user.uid).get();
    if (!snapshot.exists || snapshot.data() == null) return null;
    _cachedProfile = AppUserProfile.fromMap(snapshot.id, snapshot.data()!);
    return _cachedProfile;
  }

  @override
  Future<AppUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    var profile = await loadCurrentProfile();
    if (profile == null && credential.user != null) {
      // Repair accounts created while Firestore rules were missing. Only the
      // authenticated owner can create this student profile under our rules.
      final user = credential.user!;
      final displayName = (user.displayName ?? '').trim();
      final nameParts = displayName.split(RegExp(r'\s+'));
      await _users.doc(user.uid).set({
        'role': UserRole.student.name,
        'email': user.email ?? email.trim(),
        'firstName': displayName.isEmpty ? '' : nameParts.first,
        'lastName': nameParts.length < 2 ? '' : nameParts.skip(1).join(' '),
        'username': displayName,
        'phone': '',
        'location': '',
        'gender': '',
        'educationLevel': '',
        'currentSchool': '',
        'dateOfBirth': null,
        'photoUrl': user.photoURL,
        'schoolId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 20));
      profile = await loadCurrentProfile();
    }
    if (profile == null) {
      await _auth.signOut();
      throw StateError(
        'This account is missing its ElimuPath user profile. Contact support.',
      );
    }
    return profile;
  }

  @override
  Future<AppUserProfile> registerStudent(
    StudentRegistration registration,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: registration.email.trim(),
      password: registration.password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not create the account.');

    final data = <String, dynamic>{
      'role': UserRole.student.name,
      'email': registration.email.trim(),
      'firstName': registration.firstName.trim(),
      'lastName': registration.lastName.trim(),
      'username': registration.username.trim(),
      'phone': registration.phone.trim(),
      'location': registration.location.trim(),
      'gender': registration.gender.trim(),
      'educationLevel': registration.educationLevel.trim(),
      'currentSchool': registration.currentSchool.trim(),
      'dateOfBirth': Timestamp.fromDate(registration.dateOfBirth),
      'photoUrl': null,
      'schoolId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    try {
      // Create the required Firestore profile before handling the optional
      // photo, so a slow or unavailable Storage service cannot block signup.
      await _users.doc(user.uid).set(data).timeout(const Duration(seconds: 20));
      await user.updateDisplayName(
        '${registration.firstName} ${registration.lastName}'.trim(),
      );
    } catch (_) {
      // Avoid leaving an Authentication account with no matching profile.
      await user.delete().catchError((_) {});
      rethrow;
    }

    if (registration.photo != null) {
      try {
        final photoUrl = await _upload(
          path:
              'users/${user.uid}/profile/${DateTime.now().microsecondsSinceEpoch}-${registration.photo!.fileName}',
          data: registration.photo!,
        ).timeout(const Duration(seconds: 20));
        await _users.doc(user.uid).update({
          'photoUrl': photoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 20));
      } on FirebaseException {
        // The account remains usable when optional Storage is unavailable.
      } on TimeoutException {
        // Do not keep the registration screen loading for an optional photo.
      }
    }

    final profile = await loadCurrentProfile();
    if (profile == null) throw StateError('Unable to load the new profile.');
    return profile;
  }

  @override
  Future<AppUserProfile> registerSchoolAdmin(
    SchoolAdminRegistration registration,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: registration.email.trim(),
      password: registration.password,
    );
    final user = credential.user;
    if (user == null) throw StateError('Firebase did not create the account.');

    final schoolId = user.uid;
    final batch = _firestore.batch();
    batch.set(_users.doc(user.uid), {
      'role': UserRole.schoolAdmin.name,
      'email': registration.email.trim(),
      'firstName': '',
      'lastName': '',
      'username': registration.username.trim(),
      'phone': registration.phone.trim(),
      'location': registration.district.trim(),
      'gender': '',
      'educationLevel': '',
      'currentSchool': registration.schoolName.trim(),
      'photoUrl': null,
      'schoolId': schoolId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_schools.doc(schoolId), {
      'name': registration.schoolName.trim(),
      'district': registration.district.trim(),
      'location': registration.district.trim(),
      'type': '',
      'sector': '',
      'gender': 'Mixed',
      'combinations': <String>[],
      'educationStages': <String>[],
      'schoolFees': 0,
      'admissionStatus': true,
      'isActive': true,
      'availableSpots': 0,
      'performanceIndex': 0,
      'facilities': <String>[],
      'photos': <String>[],
      'imageUrls': <String>[],
      'verified': false,
      'ownerId': user.uid,
      'adminId': user.uid,
      'email': registration.email.trim(),
      'phone': registration.phone.trim(),
      'contact': registration.phone.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit().timeout(const Duration(seconds: 20));
      await user.updateDisplayName(registration.username.trim());
    } catch (_) {
      await user.delete().catchError((_) {});
      rethrow;
    }
    final profile = await loadCurrentProfile();
    if (profile == null) throw StateError('Unable to load the new profile.');
    return profile;
  }

  @override
  Future<void> signOut() async {
    _cachedProfile = null;
    await _auth.signOut();
  }

  @override
  Stream<AppUserProfile?> watchCurrentProfile() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        _cachedProfile = null;
        return Stream.value(null);
      }
      return _users.doc(user.uid).snapshots().map((snapshot) {
        final data = snapshot.data();
        if (data == null) return null;
        _cachedProfile = AppUserProfile.fromMap(snapshot.id, data);
        return _cachedProfile;
      });
    });
  }

  @override
  Stream<List<SchoolModel>> watchSchools() {
    return _schools
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => SchoolModel.fromMap(doc.id, doc.data()))
                  .toList(growable: false)
                ..sort(
                  (first, second) => first.name.toLowerCase().compareTo(
                    second.name.toLowerCase(),
                  ),
                ),
        );
  }

  @override
  Stream<SchoolModel?> watchSchool(String schoolId) {
    if (schoolId.isEmpty) return Stream.value(null);
    return _schools.doc(schoolId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : SchoolModel.fromMap(snapshot.id, data);
    });
  }

  @override
  Stream<SchoolModel?> watchCurrentSchool() async* {
    final profile = _cachedProfile ?? await loadCurrentProfile();
    final schoolId = profile?.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      yield null;
      return;
    }
    yield* watchSchool(schoolId);
  }

  @override
  Stream<List<ApplicationModel>> watchMyApplications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _applications
        .where('studentId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Stream<List<ApplicationModel>> watchSchoolApplications() async* {
    final profile = _cachedProfile ?? await loadCurrentProfile();
    final schoolId = profile?.schoolId;
    if (schoolId == null || schoolId.isEmpty) {
      yield const [];
      return;
    }
    yield* _applications
        .where('schoolId', isEqualTo: schoolId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ApplicationModel.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Stream<ApplicationModel?> watchApplication(String applicationId) {
    if (applicationId.isEmpty) return Stream.value(null);
    return _applications.doc(applicationId).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : ApplicationModel.fromMap(snapshot.id, data);
    });
  }

  @override
  Stream<Set<String>> watchFavoriteSchoolIds() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const {});
    return _favorites
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data()['schoolId'])
              .whereType<String>()
              .toSet(),
        );
  }

  @override
  Future<void> toggleFavorite(String schoolId) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before saving favorites.');
    final reference = _favorites.doc('${user.uid}_$schoolId');
    final snapshot = await reference.get();
    if (snapshot.exists) {
      await reference.delete();
    } else {
      await reference.set({
        'userId': user.uid,
        'schoolId': schoolId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<bool> submitApplication(ApplicationDraft draft) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before applying.');
    final profile = _cachedProfile ?? await loadCurrentProfile();
    if (profile == null) throw StateError('Your user profile is unavailable.');
    final schoolSnapshot = await _schools
        .doc(draft.schoolId)
        .get()
        .timeout(const Duration(seconds: 20));
    final schoolData = schoolSnapshot.data();
    if (schoolData == null) {
      throw StateError('The selected school was removed.');
    }
    final school = SchoolModel.fromMap(schoolSnapshot.id, schoolData);

    String? transcriptUrl;
    if (draft.transcript != null) {
      try {
        transcriptUrl = await _upload(
          path:
              'applications/${user.uid}/${school.id}/${DateTime.now().microsecondsSinceEpoch}-${draft.transcript!.fileName}',
          data: draft.transcript!,
        ).timeout(const Duration(seconds: 20));
      } on FirebaseException {
        // Storage is optional: submit the application without an attachment
        // when the project's Storage bucket has not been provisioned yet.
      } on TimeoutException {
        // Never leave the application form waiting indefinitely on Storage.
      }
    }

    await _applications.add({
      'studentId': user.uid,
      'studentName': draft.names.trim(),
      'studentEmail': draft.email.trim(),
      'studentPhone': profile.phone,
      'studentLocation': profile.location,
      'studentGender': profile.gender,
      'studentDateOfBirth': profile.dateOfBirth == null
          ? null
          : Timestamp.fromDate(profile.dateOfBirth!),
      'educationLevel': draft.educationLevel.trim(),
      'currentSchool': draft.currentSchool.trim(),
      'schoolId': school.id,
      'schoolName': school.name,
      'transcriptUrl': transcriptUrl,
      'status': ApplicationStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 20));
    return draft.transcript == null || transcriptUrl != null;
  }

  @override
  Future<void> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    await _applications.doc(applicationId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'reviewedBy': _auth.currentUser?.uid,
    });
  }

  @override
  Future<void> updateSchool(
    SchoolModel school, {
    String? username,
    String? newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in before editing a school.');
    final batch = _firestore.batch();
    batch.update(_schools.doc(school.id), {
      ...school.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (username != null && username.trim().isNotEmpty) {
      batch.update(_users.doc(user.uid), {
        'username': username.trim(),
        'phone': school.phone,
        'location': school.location,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit().timeout(const Duration(seconds: 20));
    if (newPassword != null && newPassword.isNotEmpty) {
      await user.updatePassword(newPassword);
    }
    await loadCurrentProfile().timeout(const Duration(seconds: 20));
  }

  @override
  Future<String> uploadSchoolImage(UploadData image) async {
    final user = _auth.currentUser;
    final profile = _cachedProfile ?? await loadCurrentProfile();
    if (user == null || profile?.schoolId == null) {
      throw StateError('Only a school administrator can upload images.');
    }
    return _upload(
      path:
          'schools/${profile!.schoolId}/${DateTime.now().microsecondsSinceEpoch}-${image.fileName}',
      data: image,
    ).timeout(const Duration(seconds: 20));
  }

  Future<String> _upload({
    required String path,
    required UploadData data,
  }) async {
    final metadata = data.contentType == null
        ? null
        : SettableMetadata(contentType: data.contentType);
    final task = await _storage.ref(path).putData(data.bytes, metadata);
    return task.ref.getDownloadURL();
  }
}
