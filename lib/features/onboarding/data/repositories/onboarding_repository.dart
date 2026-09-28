import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/exam_model.dart';
import '../models/student_profile_model.dart';

class OnboardingRepository {
  OnboardingRepository({
    required this._apiClient,
  });

  final ApiClient _apiClient;

  Future<StudentProfile> getStudentProfile() async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.studentProfile,
    );

    return StudentProfile.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<StudentProfile> updateBasicInfo({
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    required String city,
    required String pincode,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.studentProfileBasicInfo,
      data: {
        'full_name': fullName,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'city': city,
        'pincode': pincode,
      },
    );

    return StudentProfile.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<StudentProfile> updateEducation({
    required String schoolOrCollege,
    required String educationLevel,
    required String classOrYear,
    required String studyStatus,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.studentProfileEducation,
      data: {
        'school_or_college': schoolOrCollege,
        'education_level': educationLevel,
        'class_or_year': classOrYear,
        'study_status': studyStatus,
      },
    );

    return StudentProfile.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<StudentProfile> updateExam({
    required String examId,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.studentProfileExam,
      data: {
        'exam_id': examId,
      },
    );

    return StudentProfile.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<Exam>> getExams() async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.exams,
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => Exam.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  String extractErrorMessage(Object error) {
    if (error is! DioException) {
      return 'Something went wrong. Please try again.';
    }

    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final detail = responseData['detail'];

      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        return detail.map((item) {
          if (item is Map<String, dynamic>) {
            return item['msg']?.toString() ?? 'Validation error';
          }

          return item.toString();
        }).join('\n');
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server.';

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Please try again.';

      default:
        return 'Something went wrong. Please try again.';
    }
  }
}