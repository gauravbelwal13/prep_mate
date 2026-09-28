class StudentProfile {
  const StudentProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.pincode,
    this.schoolOrCollege,
    this.educationLevel,
    this.classOrYear,
    this.studyStatus,
    this.examId,
  });

  final String id;
  final String userId;
  final String fullName;

  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? city;
  final String? pincode;

  final String? schoolOrCollege;
  final String? educationLevel;
  final String? classOrYear;
  final String? studyStatus;

  final String? examId;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      pincode: json['pincode'] as String?,
      schoolOrCollege: json['school_or_college'] as String?,
      educationLevel: json['education_level'] as String?,
      classOrYear: json['class_or_year'] as String?,
      studyStatus: json['study_status'] as String?,
      examId: json['exam_id'] as String?,
    );
  }
  
}

extension StudentProfileOnboarding on StudentProfile {
  bool get isBasicInfoComplete {
    return phone != null &&
        phone!.isNotEmpty &&
        dateOfBirth != null &&
        dateOfBirth!.isNotEmpty &&
        gender != null &&
        gender!.isNotEmpty &&
        city != null &&
        city!.isNotEmpty &&
        pincode != null &&
        pincode!.isNotEmpty;
  }

  bool get isEducationComplete {
    return schoolOrCollege != null &&
        schoolOrCollege!.isNotEmpty &&
        educationLevel != null &&
        educationLevel!.isNotEmpty &&
        classOrYear != null &&
        classOrYear!.isNotEmpty &&
        studyStatus != null &&
        studyStatus!.isNotEmpty;
  }

  bool get isExamComplete {
    return examId != null && examId!.isNotEmpty;
  }

  bool get isOnboardingComplete {
    return isBasicInfoComplete &&
        isEducationComplete &&
        isExamComplete;
  }
}