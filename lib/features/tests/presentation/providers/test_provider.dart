import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/attempt_model.dart';
import '../../data/models/test_model.dart';
import '../../data/models/test_question_model.dart';
import '../../data/repositories/test_repository.dart';

final testRepositoryProvider = Provider<TestRepository>((ref) {
  return TestRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});

final testProvider =
    FutureProvider.family<TestModel, String>((ref, testId) {
  return ref.watch(testRepositoryProvider).getTest(testId);
});

final testQuestionsProvider =
    FutureProvider.family<List<TestQuestionModel>, String>(
  (ref, testId) {
    return ref.watch(testRepositoryProvider).getTestQuestions(testId);
  },
);

final attemptResultProvider =
    FutureProvider.family<AttemptResultModel, String>(
  (ref, attemptId) {
    return ref.watch(testRepositoryProvider).getAttemptResult(attemptId);
  },
);