import 'package:codedly/features/auth/domain/entities/user.dart';

/// User model for data layer
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    required super.languagePreference,
    required super.onboardingCompleted,
    required super.createdAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      languagePreference: json['language_preference'] as String? ?? 'en',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'language_preference': languagePreference,
      'onboarding_completed': onboardingCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create UserModel from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      languagePreference: user.languagePreference,
      onboardingCompleted: user.onboardingCompleted,
      createdAt: user.createdAt,
    );
  }
}
