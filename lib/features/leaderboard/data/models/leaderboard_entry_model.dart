import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.userId,
    required super.displayName,
    required super.totalXp,
    required super.currentLevel,
    required super.lessonsCompleted,
    required super.streakCount,
    required super.rank,
    required super.xpReachedAt,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? 'Learner',
      totalXp: json['total_xp'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      streakCount: json['streak_count'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      xpReachedAt: DateTime.parse(json['xp_reached_at'] as String),
    );
  }
}
