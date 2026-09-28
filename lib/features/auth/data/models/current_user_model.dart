class CurrentUser {
  const CurrentUser({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
  });

  final String id;
  final String email;
  final String role;
  final bool isActive;

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}