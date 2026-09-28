import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/chapter_model.dart';
import '../models/subject_model.dart';
import '../models/topic_model.dart';

class AcademicRepository {
  AcademicRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;

  Future<List<Subject>> getSubjectsByExam(String examId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.academicExamSubjects}/$examId/subjects',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Invalid subjects response from server.');
      }

      return data
          .map(
            (item) => Subject.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Chapter>> getChaptersBySubject(String subjectId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.academicSubjectChapters}/$subjectId/chapters',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Invalid chapters response from server.');
      }

      return data
          .map(
            (item) => Chapter.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error));
    }
  }

  Future<List<Topic>> getTopicsByChapter(String chapterId) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiEndpoints.academicChapterTopics}/$chapterId/topics',
      );

      final data = response.data;

      if (data is! List) {
        throw Exception('Invalid topics response from server.');
      }

      return data
          .map(
            (item) => Topic.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
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

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server.';
    }

    return 'Something went wrong while loading academic data.';
  }
}