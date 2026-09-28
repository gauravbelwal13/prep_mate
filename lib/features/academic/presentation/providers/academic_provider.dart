import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/topic_model.dart';
import '../../data/repositories/academic_repository.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});

final subjectsProvider =
    FutureProvider.family<List<Subject>, String>((ref, examId) {
  return ref
      .watch(academicRepositoryProvider)
      .getSubjectsByExam(examId);
});

final chaptersProvider =
    FutureProvider.family<List<Chapter>, String>((ref, subjectId) {
  return ref
      .watch(academicRepositoryProvider)
      .getChaptersBySubject(subjectId);
});

final topicsProvider =
    FutureProvider.family<List<Topic>, String>((ref, chapterId) {
  return ref
      .watch(academicRepositoryProvider)
      .getTopicsByChapter(chapterId);
});