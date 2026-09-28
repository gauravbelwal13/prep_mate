import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/attempt_model.dart';
import '../models/test_model.dart';
import '../models/test_question_model.dart';

class TestRepository {
  TestRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<TestModel> createTest({
    required String examId,
    required String title,
    String? description,
    required List<String> questionIds,
    required int durationMinutes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.tests,
        data: {
          'exam_id': examId,
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
          'question_ids': questionIds,
          'duration_minutes': durationMinutes,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid test response.');
      }

      return TestModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<TestModel> getTest(String testId) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.testDetails(testId),
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid test response.');
      }

      return TestModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<TestQuestionModel>> getTestQuestions(
    String testId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.testQuestions(testId),
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Invalid test questions response.');
      }

      return data
          .map(
            (item) => TestQuestionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<StartAttemptModel> startAttempt(
    String testId,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.testAttempts(testId),
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid attempt response.');
      }

      return StartAttemptModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AttemptResultModel> submitAttempt({
    required String attemptId,
    required List<TestAnswerSubmission> answers,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.submitAttempt(attemptId),
        data: {
          'answers': answers
              .map(
                (answer) => answer.toJson(),
              )
              .toList(),
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid attempt result response.');
      }

      return AttemptResultModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<AttemptResultModel> getAttemptResult(
    String attemptId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.attemptResult(attemptId),
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid attempt result response.');
      }

      return AttemptResultModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  String _extractErrorMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final firstError = detail.first;

        if (firstError is Map<String, dynamic>) {
          final message = firstError['msg'];

          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      }
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }

    return 'Something went wrong. Please try again.';
  }
}

class TestAnswerSubmission {
  const TestAnswerSubmission({
    required this.questionId,
    this.selectedOptionId,
  });

  final String questionId;
  final String? selectedOptionId;

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'selected_option_id': selectedOptionId,
    };
  }
}