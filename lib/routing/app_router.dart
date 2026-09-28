import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:prep_mate/features/academic/presentation/screens/chapters_screen.dart';
import 'package:prep_mate/features/academic/presentation/screens/subjects_screen.dart';
import 'package:prep_mate/features/academic/presentation/screens/topics_screen.dart';
import 'package:prep_mate/features/auth/presentation/screens/login_screen.dart';
import 'package:prep_mate/features/auth/presentation/screens/register_screen.dart';
import 'package:prep_mate/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:prep_mate/features/onboarding/presentation/screens/basic_info_screen.dart';
import 'package:prep_mate/features/onboarding/presentation/screens/education_screen.dart';
import 'package:prep_mate/features/onboarding/presentation/screens/exam_selection_screen.dart';
import 'package:prep_mate/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:prep_mate/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:prep_mate/features/questions/data/models/question_model.dart';
import 'package:prep_mate/features/questions/presentation/screens/question_detail_screen.dart';
import 'package:prep_mate/features/questions/presentation/screens/question_practice_screen.dart';
import 'package:prep_mate/features/questions/presentation/screens/questions_screen.dart';
import 'package:prep_mate/features/tests/data/models/attempt_model.dart';
import 'package:prep_mate/features/tests/presentation/screens/create_test_screen.dart';
import 'package:prep_mate/features/tests/presentation/screens/test_preview_screen.dart';
import 'package:prep_mate/features/tests/presentation/screens/test_result_screen.dart';
import 'package:prep_mate/features/tests/presentation/screens/test_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';

  static const welcome = '/welcome';

  static const login = '/login';

  static const register = '/register';

  static const basicInfo = '/onboarding/basic-info';

  static const education = '/onboarding/education';

  static const examSelection = '/onboarding/exam-selection';

  static const dashboard = '/dashboard';

  // Tests

  static const createTest = '/tests/create';

  static String createTestForExam(String examId) {
    return '/tests/create?examId=$examId';
  }

  static const testPreview = '/tests/:testId/preview';

  static String testPreviewFor(String testId) {
    return '/tests/$testId/preview';
  }

  static const test = '/tests/:testId/attempt/:attemptId';

  static String testForAttempt({
    required String testId,
    required String attemptId,
  }) {
    return '/tests/$testId/attempt/$attemptId';
  }

  static const testResult =
      '/tests/:testId/attempt/:attemptId/result';

  static String testResultFor({
    required String testId,
    required String attemptId,
  }) {
    return '/tests/$testId/attempt/$attemptId/result';
  }

  // Academic

  static const subjects = '/academic/exams/:examId/subjects';

  static const chapters =
      '/academic/subjects/:subjectId/chapters';

  static const topics =
      '/academic/chapters/:chapterId/topics';

  // Practice receives its question list through GoRouter extra.

  static const practice = '/questions/practice';

  static String practiceFor({
    required String examId,
    required List<Question> questions,
  }) {
    return '/questions/practice?examId=$examId';
  }

  // Questions

  static const questions = '/questions';

  static const questionDetail = '/questions/:questionId';

  static String subjectsForExam(String examId) {
    return '/academic/exams/$examId/subjects';
  }

  static String chaptersForSubject({
    required String examId,
    required String subjectId,
  }) {
    return '/academic/subjects/$subjectId/chapters?examId=$examId';
  }

  static String topicsForChapter({
    required String examId,
    required String chapterId,
  }) {
    return '/academic/chapters/$chapterId/topics?examId=$examId';
  }

  static String questionsForExam(String examId) {
    return '/questions?examId=$examId';
  }

  static String questionsForSubject({
    required String examId,
    required String subjectId,
  }) {
    return '/questions?examId=$examId&subjectId=$subjectId';
  }

  static String questionsForChapter({
    required String examId,
    required String chapterId,
  }) {
    return '/questions?examId=$examId&chapterId=$chapterId';
  }

  static String questionsForTopic({
    required String examId,
    required String topicId,
  }) {
    return '/questions?examId=$examId&topicId=$topicId';
  }

  static String questionDetailFor({
    required String questionId,
    required String examId,
  }) {
    return '/questions/$questionId?examId=$examId';
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: AppRoutes.basicInfo,
      builder: (context, state) => const BasicInfoScreen(),
    ),

    GoRoute(
      path: AppRoutes.education,
      builder: (context, state) => const EducationScreen(),
    ),

    GoRoute(
      path: AppRoutes.examSelection,
      builder: (context, state) => const ExamSelectionScreen(),
    ),

    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),

    // Tests: Create

    GoRoute(
      path: AppRoutes.createTest,
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'];

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to create a test.',
          );
        }

        return CreateTestScreen(
          examId: examId,
        );
      },
    ),

    // Tests: Preview

    GoRoute(
      path: AppRoutes.testPreview,
      builder: (context, state) {
        final testId = state.pathParameters['testId'];

        if (testId == null || testId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A test is required to continue.',
          );
        }

        return TestPreviewScreen(
          testId: testId,
        );
      },
    ),

    // Tests: Active Test

    GoRoute(
      path: AppRoutes.test,
      builder: (context, state) {
        final testId = state.pathParameters['testId'];
        final attemptId = state.pathParameters['attemptId'];

        if (testId == null || testId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A test is required to continue.',
          );
        }

        if (attemptId == null || attemptId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A test attempt is required to continue.',
          );
        }

        return TestScreen(
          testId: testId,
          attemptId: attemptId,
        );
      },
    ),

    // Academic: Subjects

    GoRoute(
      path: AppRoutes.subjects,
      builder: (context, state) {
        final examId = state.pathParameters['examId'];

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to load subjects.',
          );
        }

        return SubjectsScreen(
          examId: examId,
        );
      },
    ),

    // Academic: Chapters

    GoRoute(
      path: AppRoutes.chapters,
      builder: (context, state) {
        final subjectId = state.pathParameters['subjectId'];
        final examId = state.uri.queryParameters['examId'];

        if (subjectId == null || subjectId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A subject is required to load chapters.',
          );
        }

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to continue.',
          );
        }

        return ChaptersScreen(
          examId: examId,
          subjectId: subjectId,
        );
      },
    ),

    // Academic: Topics

    GoRoute(
      path: AppRoutes.topics,
      builder: (context, state) {
        final chapterId = state.pathParameters['chapterId'];
        final examId = state.uri.queryParameters['examId'];

        if (chapterId == null || chapterId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A chapter is required to load topics.',
          );
        }

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to continue.',
          );
        }

        return TopicsScreen(
          examId: examId,
          chapterId: chapterId,
        );
      },
    ),

    // Question Bank

    GoRoute(
      path: AppRoutes.questions,
      builder: (context, state) {
        final examId = state.uri.queryParameters['examId'];

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to load questions.',
          );
        }

        final subjectId =
            state.uri.queryParameters['subjectId'];

        final chapterId =
            state.uri.queryParameters['chapterId'];

        final topicId =
            state.uri.queryParameters['topicId'];

        String title;

        if (topicId != null && topicId.isNotEmpty) {
          title = 'Topic Questions';
        } else if (chapterId != null && chapterId.isNotEmpty) {
          title = 'Chapter Questions';
        } else if (subjectId != null && subjectId.isNotEmpty) {
          title = 'Subject Questions';
        } else {
          title = 'Question Bank';
        }

        return QuestionsScreen(
          examId: examId,
          subjectId: subjectId,
          chapterId: chapterId,
          topicId: topicId,
          title: title,
        );
      },
    ),

    // Question detail

    GoRoute(
      path: AppRoutes.questionDetail,
      builder: (context, state) {
        final question = state.extra;
        final examId = state.uri.queryParameters['examId'];

        if (question is! Question) {
          return const _InvalidQuestionRoute(
            message: 'Question data is unavailable.',
          );
        }

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to check this answer.',
          );
        }

        return QuestionDetailScreen(
          question: question,
          examId: examId,
        );
      },
    ),

    // Local question practice

    GoRoute(
      path: AppRoutes.practice,
      builder: (context, state) {
        final questions = state.extra;
        final examId = state.uri.queryParameters['examId'];

        if (questions is! List<Question> || questions.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'Practice questions are unavailable.',
          );
        }

        if (examId == null || examId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'An exam is required to practice questions.',
          );
        }

        return QuestionPracticeScreen(
          examId: examId,
          questions: questions,
          title: 'Practice',
        );
      },
    ),

    // Tests: Result

    GoRoute(
      path: AppRoutes.testResult,
      builder: (context, state) {
        final testId = state.pathParameters['testId'];
        final attemptId = state.pathParameters['attemptId'];
        final result = state.extra;

        if (testId == null || testId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A test is required to view the result.',
          );
        }

        if (attemptId == null || attemptId.isEmpty) {
          return const _InvalidQuestionRoute(
            message: 'A test attempt is required to view the result.',
          );
        }

        if (result is! AttemptResultModel) {
          return const _InvalidQuestionRoute(
            message: 'Test result data is unavailable.',
          );
        }

        return TestResultScreen(
          result: result,
        );
      },
    ),
  ],
);

class _InvalidQuestionRoute extends StatelessWidget {
  const _InvalidQuestionRoute({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrepMate'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}