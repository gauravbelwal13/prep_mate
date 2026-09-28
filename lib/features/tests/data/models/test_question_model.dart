class TestQuestionModel {
  const TestQuestionModel({
    required this.questionId,
    required this.questionOrder,
    required this.questionText,
    required this.questionType,
    required this.subjectName,
    required this.chapterName,
    required this.topicName,
    this.explanation,
    this.imageUrl,
    required this.difficulty,
    required this.marks,
    required this.negativeMarks,
    required this.options,
  });

  final String questionId;
  final int questionOrder;
  final String questionText;
  final String questionType;
  final String subjectName;
  final String chapterName;
  final String topicName;
  final String? explanation;
  final String? imageUrl;
  final String difficulty;
  final int marks;
  final int negativeMarks;
  final List<TestQuestionOption> options;

  factory TestQuestionModel.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];

    return TestQuestionModel(
      questionId: json['question_id'] as String,
      questionOrder: (json['question_order'] as num).toInt(),
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      subjectName: json['subject_name'] as String,
      chapterName: json['chapter_name'] as String,
      topicName: json['topic_name'] as String,
      explanation: json['explanation'] as String?,
      imageUrl: json['image_url'] as String?,
      difficulty: json['difficulty'] as String,
      marks: (json['marks'] as num).toInt(),
      negativeMarks: (json['negative_marks'] as num).toInt(),
      options: optionsJson
          .map(
            (option) => TestQuestionOption.fromJson(
              option as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}

class TestQuestionOption {
  const TestQuestionOption({
    required this.id,
    required this.optionOrder,
    required this.optionText,
  });

  final String id;
  final int optionOrder;
  final String optionText;

  factory TestQuestionOption.fromJson(Map<String, dynamic> json) {
    return TestQuestionOption(
      id: json['id'] as String,
      optionOrder: (json['option_order'] as num).toInt(),
      optionText: json['option_text'] as String,
    );
  }
}