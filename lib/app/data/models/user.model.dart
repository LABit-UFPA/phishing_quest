import 'package:phishing_quest/app/data/enumerators/user_role.enum.dart';

/// Usuario autenticado, no formato da resposta de POST /users/login.
class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final int totalScore;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.role = UserRole.participant,
    this.totalScore = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: UserRole.fromString(json['role']),
      totalScore: json['totalScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'role': role.name,
        'totalScore': totalScore,
      };

  UserModel copyWith({int? totalScore}) => UserModel(
        id: id,
        username: username,
        email: email,
        role: role,
        totalScore: totalScore ?? this.totalScore,
      );

  bool get canCurate => role.canCurate;
}
