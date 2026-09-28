class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
  });

  final String email;
  final String password;
  final String fullName;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
    };
  }
}

class RegisterResponse {
  const RegisterResponse({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
    );
  }
}

class VerifyEmailRequest {
  const VerifyEmailRequest({
    required this.email,
    required this.otpCode,
  });

  final String email;
  final String otpCode;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp_code': otpCode,
    };
  }
}

class VerifyEmailResponse {
  const VerifyEmailResponse({
    required this.userId,
    required this.email,
    required this.emailVerified,
    required this.message,
  });

  final String userId;
  final String email;
  final bool emailVerified;
  final String message;

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      message: json['message'] as String,
    );
  }
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  final String accessToken;
  final String tokenType;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}