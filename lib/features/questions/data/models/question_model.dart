import 'question_option_model.dart';

class Question {
  const Question({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicName,
    required this.questionText,
    this.explanation,
    required this.questionType,
    this.imageUrl,
    required this.difficulty,
    required this.marks,
    required this.negativeMarks,
    required this.options,
  });

  final String id;

  final String subjectId;
  final String subjectName;

  final String chapterId;
  final String chapterName;

  final String topicId;
  final String topicName;

  final String questionText;
  final String? explanation;

  final String questionType;
  final String? imageUrl;

  final String difficulty;
  final int marks;
  final int negativeMarks;

  final List<QuestionOption> options;

  factory Question.fromJson(Map<String, dynamic> json) {
    final optionsJson = json['options'] as List<dynamic>? ?? [];

    return Question(
      id: json['id'] as String,

      subjectId: json['subject_id'] as String,
      subjectName: json['subject_name'] as String,

      chapterId: json['chapter_id'] as String,
      chapterName: json['chapter_name'] as String,

      topicId: json['topic_id'] as String,
      topicName: json['topic_name'] as String,

      questionText: json['question_text'] as String,
      explanation: json['explanation'] as String?,

      questionType: json['question_type'] as String,
      imageUrl: json['image_url'] as String?,

      difficulty: json['difficulty'] as String,
      marks: (json['marks'] as num).toInt(),
      negativeMarks: (json['negative_marks'] as num).toInt(),

      options: optionsJson
          .map(
            (option) => QuestionOption.fromJson(
              option as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}