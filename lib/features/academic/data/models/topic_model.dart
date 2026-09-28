class Topic {
  const Topic({
    required this.id,
    required this.chapterId,
    required this.name,
    this.description,
    required this.sortOrder,
  });

  final String id;
  final String chapterId;
  final String name;
  final String? description;
  final int sortOrder;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      chapterId: json['chapter_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}