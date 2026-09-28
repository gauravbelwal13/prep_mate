import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/current_user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.message,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        message = null;

  final AuthStatus status;
  final CurrentUser? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    CurrentUser? user,
    String? message,
    bool clearUser = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final authProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _tokenStorage = ref.read(tokenStorageProvider);

    return const AuthState.initial();
  }

  Future<void> initialize() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearMessage: true,
    );

    try {
      final hasToken = await _tokenStorage.hasToken();

      if (!hasToken) {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
        );
        return;
      }

      final user = await _repository.getCurrentUser();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      await _tokenStorage.clearTokens();

      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearMessage: true,
    );

    try {
      await _repository.register(
        RegisterRequest(
          email: email,
          password: password,
          fullName: fullName,
        ),
      );

      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );

      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        message: _repository.extractErrorMessage(e),
      );

      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearMessage: true,
    );

    try {
      final response = await _repository.login(
        LoginRequest(
          email: email,
          password: password,
        ),
      );

      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        tokenType: response.tokenType,
      );

      final user = await _repository.getCurrentUser();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );

      return true;
    } catch (e) {
      await _tokenStorage.clearTokens();

      state = AuthState(
        status: AuthStatus.error,
        message: _repository.extractErrorMessage(e),
      );

      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }
}