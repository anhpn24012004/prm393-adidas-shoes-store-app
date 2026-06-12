class AuthSession {
  final int userId;
  final String fullName;
  final String email;
  final String role;
  final String token;

  const AuthSession({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
