class QuestionAnswerResult {
  const QuestionAnswerResult({
    required this.questionId,
    required this.selectedOptionId,
    required this.correctOptionId,
    required this.isCorrect,
    required this.marksAwarded,
    this.explanation,
  });

  final String questionId;
  final String selectedOptionId;
  final String correctOptionId;
  final bool isCorrect;
  final int marksAwarded;
  final String? explanation;

  factory QuestionAnswerResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return QuestionAnswerResult(
      questionId: json['question_id'] as String,
      selectedOptionId: json['selected_option_id'] as String,
      correctOptionId: json['correct_option_id'] as String,
      isCorrect: json['is_correct'] as bool,
      marksAwarded: (json['marks_awarded'] as num).toInt(),
      explanation: json['explanation'] as String?,
    );
  }
}