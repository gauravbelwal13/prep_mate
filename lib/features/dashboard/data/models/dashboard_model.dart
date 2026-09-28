class DashboardSummary {
  const DashboardSummary({
    required this.student,
    this.exam,
    required this.overall,
    required this.subjects,
    required this.weakAreas,
    required this.strongAreas,
    required this.recentTests,
  });

  final DashboardStudent student;
  final DashboardExam? exam;
  final DashboardOverall overall;
  final List<DashboardSubjectPerformance> subjects;
  final List<DashboardArea> weakAreas;
  final List<DashboardArea> strongAreas;
  final List<DashboardRecentTest> recentTests;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final subjectsJson =
        json['subjects'] as List<dynamic>? ?? [];

    final weakAreasJson =
        json['weak_areas'] as List<dynamic>? ?? [];

    final strongAreasJson =
        json['strong_areas'] as List<dynamic>? ?? [];

    final recentTestsJson =
        json['recent_tests'] as List<dynamic>? ?? [];

    return DashboardSummary(
      student: DashboardStudent.fromJson(
        json['student'] as Map<String, dynamic>,
      ),
      exam: json['exam'] == null
          ? null
          : DashboardExam.fromJson(
              json['exam'] as Map<String, dynamic>,
            ),
      overall: DashboardOverall.fromJson(
        json['overall'] as Map<String, dynamic>,
      ),
      subjects: subjectsJson
          .map(
            (item) => DashboardSubjectPerformance.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      weakAreas: weakAreasJson
          .map(
            (item) => DashboardArea.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      strongAreas: strongAreasJson
          .map(
            (item) => DashboardArea.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      recentTests: recentTestsJson
          .map(
            (item) => DashboardRecentTest.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}


class DashboardStudent {
  const DashboardStudent({
    required this.name,
  });

  final String name;

  factory DashboardStudent.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardStudent(
      name: json['name'] as String,
    );
  }
}


class DashboardExam {
  const DashboardExam({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory DashboardExam.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardExam(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}


class DashboardOverall {
  const DashboardOverall({
    required this.completedTests,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.accuracy,
  });

  final int completedTests;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double accuracy;

  factory DashboardOverall.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardOverall(
      completedTests:
          (json['completed_tests'] as num).toInt(),
      attemptedQuestions:
          (json['attempted_questions'] as num).toInt(),
      correctAnswers:
          (json['correct_answers'] as num).toInt(),
      incorrectAnswers:
          (json['incorrect_answers'] as num).toInt(),
      unansweredQuestions:
          (json['unanswered_questions'] as num).toInt(),
      accuracy:
          (json['accuracy'] as num).toDouble(),
    );
  }
}


class DashboardSubjectPerformance {
  const DashboardSubjectPerformance({
    required this.subjectId,
    required this.subjectName,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
  });

  final String subjectId;
  final String subjectName;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;

  factory DashboardSubjectPerformance.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardSubjectPerformance(
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      attemptedQuestions:
          (json['attempted_questions'] as num).toInt(),
      correctAnswers:
          (json['correct_answers'] as num).toInt(),
      incorrectAnswers:
          (json['incorrect_answers'] as num).toInt(),
      accuracy:
          (json['accuracy'] as num).toDouble(),
    );
  }
}


class DashboardArea {
  const DashboardArea({
    required this.topicId,
    required this.topicName,
    required this.chapterId,
    required this.chapterName,
    required this.subjectId,
    required this.subjectName,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
  });

  final String topicId;
  final String topicName;
  final String chapterId;
  final String chapterName;
  final String subjectId;
  final String subjectName;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;

  factory DashboardArea.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardArea(
      topicId: json['topic_id'] as String,
      topicName: json['topic_name'] as String,
      chapterId: json['chapter_id'] as String,
      chapterName: json['chapter_name'] as String,
      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,
      attemptedQuestions:
          (json['attempted_questions'] as num).toInt(),
      correctAnswers:
          (json['correct_answers'] as num).toInt(),
      incorrectAnswers:
          (json['incorrect_answers'] as num).toInt(),
      accuracy:
          (json['accuracy'] as num).toDouble(),
    );
  }
}


class DashboardRecentTest {
  const DashboardRecentTest({
    required this.attemptId,
    required this.testId,
    required this.title,
    required this.submittedAt,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.score,
    required this.accuracy,
  });

  final String attemptId;
  final String testId;
  final String title;
  final DateTime submittedAt;
  final int totalQuestions;
  final int attemptedQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double score;
  final double accuracy;

  factory DashboardRecentTest.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardRecentTest(
      attemptId: json['attempt_id'] as String,
      testId: json['test_id'] as String,
      title: json['title'] as String,
      submittedAt: DateTime.parse(
        json['submitted_at'] as String,
      ),
      totalQuestions:
          (json['total_questions'] as num).toInt(),
      attemptedQuestions:
          (json['attempted_questions'] as num).toInt(),
      correctAnswers:
          (json['correct_answers'] as num).toInt(),
      incorrectAnswers:
          (json['incorrect_answers'] as num).toInt(),
      unansweredQuestions:
          (json['unanswered_questions'] as num).toInt(),
      score:
          (json['score'] as num).toDouble(),
      accuracy:
          (json['accuracy'] as num).toDouble(),
    );
  }
}