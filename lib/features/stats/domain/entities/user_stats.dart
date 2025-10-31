import 'package:equatable/equatable.dart';

/// User statistics entity.
///
/// Represents a user's learning progress and achievements.
class UserStats extends Equatable {
  /// The user's unique identifier.
  final String userId;

  /// Total XP earned by the user.
  final int totalXp;

  /// Current level based on XP.
  final int currentLevel;

  /// Current streak count in days.
  final int streakCount;

  /// Total number of lessons completed.
  final int lessonsCompleted;

  /// Total number of quizzes completed.
  final int quizzesCompleted;

  /// Date when stats were last updated.
  final DateTime updatedAt;

  const UserStats({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.streakCount,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
    required this.updatedAt,
  });

  /// Creates a copy of this [UserStats] with the given fields replaced.
  UserStats copyWith({
    String? userId,
    int? totalXp,
    int? currentLevel,
    int? streakCount,
    int? lessonsCompleted,
    int? quizzesCompleted,
    DateTime? updatedAt,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      streakCount: streakCount ?? this.streakCount,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    totalXp,
    currentLevel,
    streakCount,
    lessonsCompleted,
    quizzesCompleted,
    updatedAt,
  ];
}
