class StartAttemptModel {
  const StartAttemptModel({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.startedAt,
    required this.totalQuestions,
    required this.status,
  });

  final String id;
  final String testId;
  final String studentId;
  final DateTime startedAt;
  final int totalQuestions;
  final String status;

  factory StartAttemptModel.fromJson(Map<String, dynamic> json) {
    return StartAttemptModel(
      id: json['id'] as String,
      testId: json['test_id'] as String,
      studentId: json['student_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      totalQuestions: (json['total_questions'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}

class AttemptResultModel {
  const AttemptResultModel({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.startedAt,
    required this.submittedAt,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.score,
    required this.accuracy,
  });

  final String id;
  final String testId;
  final String studentId;
  final DateTime startedAt;
  final DateTime submittedAt;
  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double score;
  final double accuracy;

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    return AttemptResultModel(
      id: json['id'] as String,
      testId: json['test_id'] as String,
      studentId: json['student_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      totalQuestions: (json['total_questions'] as num).toInt(),
      attemptedQuestions: (json['attempted_questions'] as num).toInt(),
      correctAnswers: (json['correct_answers'] as num).toInt(),
      incorrectAnswers: (json['incorrect_answers'] as num).toInt(),
      unansweredQuestions: (json['unanswered_questions'] as num).toInt(),
      score: (json['score'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
    );
  }
}