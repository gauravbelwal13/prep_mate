import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/question_repository.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});

class QuestionFilter {
  const QuestionFilter({
    required this.examId,
    this.subjectId,
    this.chapterId,
    this.topicId,
    this.difficulty,
    this.limit = 20,
  });

  final String examId;
  final String? subjectId;
  final String? chapterId;
  final String? topicId;
  final String? difficulty;
  final int limit;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is QuestionFilter &&
        other.examId == examId &&
        other.subjectId == subjectId &&
        other.chapterId == chapterId &&
        other.topicId == topicId &&
        other.difficulty == difficulty &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return Object.hash(
      examId,
      subjectId,
      chapterId,
      topicId,
      difficulty,
      limit,
    );
  }
}

final questionsProvider =
    FutureProvider.family<List<Question>, QuestionFilter>(
  (ref, filter) {
    return ref.watch(questionRepositoryProvider).getQuestions(
          examId: filter.examId,
          subjectId: filter.subjectId,
          chapterId: filter.chapterId,
          topicId: filter.topicId,
          difficulty: filter.difficulty,
          limit: filter.limit,
        );
  },
);