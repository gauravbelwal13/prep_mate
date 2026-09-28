import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/question_answer_result_model.dart';
import '../models/question_model.dart';

class QuestionRepository {
  QuestionRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<Question>> getQuestions({
    required String examId,
    String? subjectId,
    String? chapterId,
    String? topicId,
    String? difficulty,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.questions,
        queryParameters: {
          'exam_id': examId,
          if (subjectId != null) 'subject_id': subjectId,
          if (chapterId != null) 'chapter_id': chapterId,
          if (topicId != null) 'topic_id': topicId,
          if (difficulty != null) 'difficulty': difficulty,
          'limit': limit,
        },
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Invalid questions response.');
      }

      return data
          .map(
            (item) => Question.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<QuestionAnswerResult> checkAnswer({
    required String questionId,
    required String examId,
    required String selectedOptionId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiEndpoints.questions}/$questionId/check-answer',
        data: {
          'exam_id': examId,
          'selected_option_id': selectedOptionId,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid answer check response.');
      }

      return QuestionAnswerResult.fromJson(data);
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
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }

    return 'Unable to load questions.';
  }
}