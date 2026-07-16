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

class UserProfile {
  final int userId;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String role;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final dateText = json['dateOfBirth']?.toString();

    return UserProfile(
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: dateText == null || dateText.isEmpty
          ? null
          : DateTime.tryParse(dateText),
      role: json['role'] ?? '',
    );
  }
}
