class TestModel {
  const TestModel({
    required this.id,
    required this.examId,
    required this.examName,
    required this.title,
    this.description,
    required this.totalQuestions,
    required this.durationMinutes,
    required this.status,
  });

  final String id;
  final String examId;
  final String examName;
  final String title;
  final String? description;
  final int totalQuestions;
  final int durationMinutes;
  final String status;

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      examName: json['exam_name'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      totalQuestions: (json['total_questions'] as num).toInt(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      status: json['status'] as String,
    );
  }
}