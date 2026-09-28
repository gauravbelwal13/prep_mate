import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/auth_models.dart';
import '../models/current_user_model.dart';

class AuthRepository {
  AuthRepository({
    required this._apiClient,
    required this._tokenStorage,
  });

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    return RegisterResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );

    return LoginResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<CurrentUser> getCurrentUser() async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.currentUser,
    );

    return CurrentUser.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
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