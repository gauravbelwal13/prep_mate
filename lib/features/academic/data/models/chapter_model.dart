class Chapter {
  const Chapter({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    required this.sortOrder,
  });

  final String id;
  final String subjectId;
  final String name;
  final String? description;
  final int sortOrder;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}