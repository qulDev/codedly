import 'package:codedly/features/stats/domain/entities/user_stats.dart';

/// User statistics data model.
///
/// Extends [UserStats] with JSON serialization capabilities.
class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.userId,
    required super.totalXp,
    required super.currentLevel,
    required super.streakCount,
    required super.lessonsCompleted,
    required super.quizzesCompleted,
    required super.updatedAt,
  });

  /// Creates a [UserStatsModel] from JSON.
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] as String,
      totalXp: json['total_xp'] as int,
      currentLevel: json['current_level'] as int,
      streakCount: json['streak_count'] as int,
      lessonsCompleted: json['lessons_completed'] as int,
      quizzesCompleted: json['quizzes_completed'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [UserStatsModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_xp': totalXp,
      'current_level': currentLevel,
      'streak_count': streakCount,
      'lessons_completed': lessonsCompleted,
      'quizzes_completed': quizzesCompleted,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
