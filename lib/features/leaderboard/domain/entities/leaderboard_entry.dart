import 'package:equatable/equatable.dart';

/// Leaderboard entry representing a learner's XP standing.
class LeaderboardEntry extends Equatable {
  final String userId;
  final String displayName;
  final int totalXp;
  final int currentLevel;
  final int lessonsCompleted;
  final int streakCount;
  final int rank;
  final DateTime xpReachedAt;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.totalXp,
    required this.currentLevel,
    required this.lessonsCompleted,
    required this.streakCount,
    required this.rank,
    required this.xpReachedAt,
  });

  LeaderboardEntry copyWith({
    String? userId,
    String? displayName,
    int? totalXp,
    int? currentLevel,
    int? lessonsCompleted,
    int? streakCount,
    int? rank,
    DateTime? xpReachedAt,
  }) {
    return LeaderboardEntry(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      streakCount: streakCount ?? this.streakCount,
      rank: rank ?? this.rank,
      xpReachedAt: xpReachedAt ?? this.xpReachedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    displayName,
    totalXp,
    currentLevel,
    lessonsCompleted,
    streakCount,
    rank,
    xpReachedAt,
  ];
}
