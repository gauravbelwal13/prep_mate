import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prep_mate/features/auth/presentation/providers/auth_provider.dart';
import 'package:prep_mate/features/onboarding/data/models/student_profile_model.dart';
import '../../data/models/exam_model.dart';
import '../../data/repositories/onboarding_repository.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(
    apiClient: ref.watch(apiClientProvider),
  );
});

final examsProvider = FutureProvider<List<Exam>>((ref) {
  return ref.watch(onboardingRepositoryProvider).getExams();
});

final studentProfileProvider = FutureProvider<StudentProfile>((ref) {
  return ref.watch(onboardingRepositoryProvider).getStudentProfile();
});