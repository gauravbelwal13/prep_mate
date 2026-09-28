class ApiEndpoints {
  ApiEndpoints._();

  static const String register =
      '/api/v1/auth/register';

  static const String verifyEmail =
      '/api/v1/auth/verify-email';

  static const String resendOtp =
      '/api/v1/auth/resend-otp';

  static const String login =
      '/api/v1/auth/login';

  static const String currentUser =
      '/api/v1/users/me';

  // Onboarding

  static const String studentProfileBasicInfo =
      '/api/v1/students/profile/basic-info';

  static const String studentProfileEducation =
      '/api/v1/students/profile/education';

  static const String studentProfileExam =
      '/api/v1/students/profile/exam';

  static const String studentProfile =
      '/api/v1/students/profile';

  static const String exams =
      '/api/v1/exams';

  // Academic

  static const String academicExamSubjects =
      '/api/v1/academic/exams';

  static const String academicSubjectChapters =
      '/api/v1/academic/subjects';

  static const String academicChapterTopics =
      '/api/v1/academic/chapters';

  // Questions

  static const String questions =
      '/api/v1/questions';

  // Tests

  static const String tests =
      '/api/v1/tests';

  static String testDetails(
    String testId,
  ) {
    return '/api/v1/tests/$testId';
  }

  static String testQuestions(
    String testId,
  ) {
    return '/api/v1/tests/$testId/questions';
  }

  // Attempts

  static String testAttempts(
    String testId,
  ) {
    return '/api/v1/tests/$testId/attempts';
  }

  static String submitAttempt(
    String attemptId,
  ) {
    return '/api/v1/attempts/$attemptId/submit';
  }

  static String attemptResult(
    String attemptId,
  ) {
    return '/api/v1/attempts/$attemptId';
  }

  // Dashboard

  static const String dashboardSummary =
      '/api/v1/dashboard/summary';
}