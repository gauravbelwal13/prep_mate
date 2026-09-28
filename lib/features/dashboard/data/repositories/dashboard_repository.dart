import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/dashboard_model.dart';


class DashboardRepository {
  DashboardRepository({
    required this.apiClient,
  });

  final ApiClient apiClient;


  Future<DashboardSummary> getSummary() async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.dashboardSummary,
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid dashboard response.',
        );
      }

      return DashboardSummary.fromJson(data);
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error),
      );
    }
  }


  String _extractErrorMessage(
    DioException error,
  ) {
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

    if (error.message != null &&
        error.message!.isNotEmpty) {
      return error.message!;
    }

    return 'Unable to load dashboard.';
  }
}