class QuestionOption {
  const QuestionOption({
    required this.id,
    required this.optionOrder,
    required this.optionText,
  });

  final String id;
  final int optionOrder;
  final String optionText;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      optionOrder: (json['option_order'] as num).toInt(),
      optionText: json['option_text'] as String,
    );
  }
}