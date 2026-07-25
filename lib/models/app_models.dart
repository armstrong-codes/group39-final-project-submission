import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  schoolAdmin;

  static UserRole fromValue(Object? value) {
    return value == 'schoolAdmin' ? schoolAdmin : student;
  }
}

enum ApplicationStatus {
  pending,
  approved,
  onHold,
  denied;

  static ApplicationStatus fromValue(Object? value) {
    return switch (value) {
      'approved' => approved,
      'onHold' => onHold,
      'denied' => denied,
      _ => pending,
    };
  }

  String get label => switch (this) {
    pending => 'Submitted',
    approved => 'Approved',
    onHold => 'On hold',
    denied => 'Denied',
  };
}

DateTime _dateFromValue(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  return DateTime.now();
}

List<String> _stringList(Object? value) {
  if (value is! Iterable) return const [];
  return value.whereType<String>().toList(growable: false);
}

String _educationLevelFromValue(Object? value) {
  return (value as String? ?? '').replaceFirst('Senoir', 'Senior');
}

class AppUserProfile {
  const AppUserProfile({
    required this.id,
    required this.role,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    required this.location,
    required this.gender,
    required this.educationLevel,
    required this.currentSchool,
    required this.createdAt,
    this.dateOfBirth,
    this.photoUrl,
    this.schoolId,
  });

  factory AppUserProfile.fromMap(String id, Map<String, dynamic> data) {
    return AppUserProfile(
      id: id,
      role: UserRole.fromValue(data['role']),
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      username: data['username'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      location: data['location'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      educationLevel: _educationLevelFromValue(data['educationLevel']),
      currentSchool: data['currentSchool'] as String? ?? '',
      dateOfBirth: data['dateOfBirth'] == null
          ? null
          : _dateFromValue(data['dateOfBirth']),
      photoUrl: data['photoUrl'] as String?,
      schoolId: data['schoolId'] as String?,
      createdAt: _dateFromValue(data['createdAt']),
    );
  }

  final String id;
  final UserRole role;
  final String email;
  final String firstName;
  final String lastName;
  final String username;
  final String phone;
  final String location;
  final String gender;
  final String educationLevel;
  final String currentSchool;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String? schoolId;
  final DateTime createdAt;

  String get displayName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }
}

class SchoolModel {
  const SchoolModel({
    required this.id,
    required this.name,
    required this.location,
    required this.sector,
    required this.level,
    required this.educationStages,
    required this.availableSpots,
    required this.availableSpotsLevel,
    required this.availableSpotsClass,
    required this.schoolFees,
    required this.email,
    required this.phone,
    required this.imageUrls,
    required this.ownerId,
    required this.isActive,
    this.district = '',
    this.type = '',
    this.gender = '',
    this.combinations = const [],
    this.admissionStatus = true,
    this.performanceIndex = 0,
    this.facilities = const [],
    this.verified = false,
    this.createdAt,
  });

  factory SchoolModel.fromMap(String id, Map<String, dynamic> data) {
    return SchoolModel(
      id: id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      sector: data['sector'] as String? ?? '',
      level: data['level'] as String? ?? '',
      educationStages: _stringList(data['educationStages']),
      availableSpots: (data['availableSpots'] as num?)?.toInt() ?? 0,
      availableSpotsLevel: data['availableSpotsLevel'] as String? ?? '',
      availableSpotsClass: data['availableSpotsClass'] as String? ?? '',
      schoolFees: (data['schoolFees'] as num?)?.toInt() ?? 0,
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      imageUrls: _stringList(data['imageUrls']),
      ownerId: data['ownerId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      district: data['district'] as String? ?? '',
      type: data['type'] as String? ?? data['sector'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      combinations: _stringList(data['combinations']),
      admissionStatus:
          data['admissionStatus'] as bool? ?? data['isActive'] as bool? ?? true,
      performanceIndex:
          (data['performanceIndex'] as num?)?.toDouble() ?? 0,
      facilities: _stringList(data['facilities']),
      verified: data['verified'] as bool? ?? false,
      createdAt: data['createdAt'] == null
          ? null
          : _dateFromValue(data['createdAt']),
    );
  }

  final String id;
  final String name;
  final String location;
  final String sector;
  final String level;
  final List<String> educationStages;
  final int availableSpots;
  final String availableSpotsLevel;
  final String availableSpotsClass;
  final int schoolFees;
  final String email;
  final String phone;
  final List<String> imageUrls;
  final String ownerId;
  final bool isActive;
  final String district;
  final String type;
  final String gender;
  final List<String> combinations;
  final bool admissionStatus;
  final double performanceIndex;
  final List<String> facilities;
  final bool verified;
  final DateTime? createdAt;

  String get formattedFees {
    final digits = schoolFees.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${buffer.toString()} rfw';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'sector': sector,
      'level': level,
      'educationStages': educationStages,
      'availableSpots': availableSpots,
      'availableSpotsLevel': availableSpotsLevel,
      'availableSpotsClass': availableSpotsClass,
      'schoolFees': schoolFees,
      'email': email,
      'phone': phone,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'isActive': isActive,
      'district': district,
      'type': type,
      'gender': gender,
      'combinations': combinations,
      'admissionStatus': admissionStatus,
      'performanceIndex': performanceIndex,
      'facilities': facilities,
      'verified': verified,
    };
  }

  SchoolModel copyWith({
    String? name,
    String? location,
    String? sector,
    String? level,
    List<String>? educationStages,
    int? availableSpots,
    String? availableSpotsLevel,
    String? availableSpotsClass,
    int? schoolFees,
    String? email,
    String? phone,
    List<String>? imageUrls,
  }) {
    return SchoolModel(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      sector: sector ?? this.sector,
      level: level ?? this.level,
      educationStages: educationStages ?? this.educationStages,
      availableSpots: availableSpots ?? this.availableSpots,
      availableSpotsLevel: availableSpotsLevel ?? this.availableSpotsLevel,
      availableSpotsClass: availableSpotsClass ?? this.availableSpotsClass,
      schoolFees: schoolFees ?? this.schoolFees,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrls: imageUrls ?? this.imageUrls,
      ownerId: ownerId,
      isActive: isActive,
      district: district,
      type: type,
      gender: gender,
      combinations: combinations,
      admissionStatus: admissionStatus,
      performanceIndex: performanceIndex,
      facilities: facilities,
      verified: verified,
      createdAt: createdAt,
    );
  }
}

class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.body,
    required this.postedAt,
    required this.postedBy,
  });

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> data) {
    return AnnouncementModel(
      id: id,
      schoolId: data['schoolId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      postedAt: _dateFromValue(data['postedAt']),
      postedBy: data['postedBy'] as String? ?? '',
    );
  }

  final String id;
  final String schoolId;
  final String title;
  final String body;
  final DateTime postedAt;
  final String postedBy;
}

class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.addedAt,
  });

  factory FavoriteModel.fromMap(String id, Map<String, dynamic> data) {
    return FavoriteModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      schoolId: data['schoolId'] as String? ?? '',
      addedAt: _dateFromValue(data['addedAt']),
    );
  }

  final String id;
  final String userId;
  final String schoolId;
  final DateTime addedAt;
}

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.educationLevel,
    required this.currentSchool,
    required this.schoolId,
    required this.schoolName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.studentPhone = '',
    this.studentLocation = '',
    this.studentGender = '',
    this.studentDateOfBirth,
    this.transcriptUrl,
  });

  factory ApplicationModel.fromMap(String id, Map<String, dynamic> data) {
    return ApplicationModel(
      id: id,
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      studentEmail: data['studentEmail'] as String? ?? '',
      studentPhone: data['studentPhone'] as String? ?? '',
      studentLocation: data['studentLocation'] as String? ?? '',
      studentGender: data['studentGender'] as String? ?? '',
      studentDateOfBirth: data['studentDateOfBirth'] == null
          ? null
          : _dateFromValue(data['studentDateOfBirth']),
      educationLevel: _educationLevelFromValue(data['educationLevel']),
      currentSchool: data['currentSchool'] as String? ?? '',
      schoolId: data['schoolId'] as String? ?? '',
      schoolName: data['schoolName'] as String? ?? '',
      transcriptUrl: data['transcriptUrl'] as String?,
      status: ApplicationStatus.fromValue(data['status']),
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String studentLocation;
  final String studentGender;
  final DateTime? studentDateOfBirth;
  final String educationLevel;
  final String currentSchool;
  final String schoolId;
  final String schoolName;
  final String? transcriptUrl;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationModel copyWith({ApplicationStatus? status}) {
    return ApplicationModel(
      id: id,
      studentId: studentId,
      studentName: studentName,
      studentEmail: studentEmail,
      studentPhone: studentPhone,
      studentLocation: studentLocation,
      studentGender: studentGender,
      studentDateOfBirth: studentDateOfBirth,
      educationLevel: educationLevel,
      currentSchool: currentSchool,
      schoolId: schoolId,
      schoolName: schoolName,
      transcriptUrl: transcriptUrl,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class StudentRegistration {
  const StudentRegistration({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.educationLevel,
    required this.currentSchool,
    required this.location,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
    this.photo,
  });

  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dateOfBirth;
  final String educationLevel;
  final String currentSchool;
  final String location;
  final String email;
  final String phone;
  final String username;
  final String password;
  final UploadData? photo;
}

class SchoolAdminRegistration {
  const SchoolAdminRegistration({
    required this.schoolName,
    required this.district,
    required this.email,
    required this.phone,
    required this.username,
    required this.password,
  });

  final String schoolName;
  final String district;
  final String email;
  final String phone;
  final String username;
  final String password;
}

class ApplicationDraft {
  const ApplicationDraft({
    required this.schoolId,
    required this.names,
    required this.email,
    required this.educationLevel,
    required this.currentSchool,
    this.transcript,
  });

  final String schoolId;
  final String names;
  final String email;
  final String educationLevel;
  final String currentSchool;
  final UploadData? transcript;
}

class UploadData {
  const UploadData({
    required this.bytes,
    required this.fileName,
    this.contentType,
  });

  final Uint8List bytes;
  final String fileName;
  final String? contentType;
}

class DashboardStats {
  const DashboardStats({
    required this.total,
    required this.approved,
    required this.onHold,
    required this.denied,
  });

  factory DashboardStats.fromApplications(
    Iterable<ApplicationModel> applications,
  ) {
    var approved = 0;
    var onHold = 0;
    var denied = 0;
    var total = 0;
    for (final application in applications) {
      total++;
      switch (application.status) {
        case ApplicationStatus.approved:
          approved++;
        case ApplicationStatus.onHold:
          onHold++;
        case ApplicationStatus.denied:
          denied++;
        case ApplicationStatus.pending:
          break;
      }
    }
    return DashboardStats(
      total: total,
      approved: approved,
      onHold: onHold,
      denied: denied,
    );
  }

  final int total;
  final int approved;
  final int onHold;
  final int denied;
}
