import 'dart:math';

/// XP and gamification constants for Codedly
class XPConstants {
  XPConstants._();

  /// XP rewards for different activities
  static const int xpPerLessonComplete = 10;
  static const int xpPerQuizPerfect = 15;
  static const int xpPerQuizPass = 10; // 80%+ correct
  static const int xpPerQuizAttempt = 5; // Below 80%
  static const int xpPerDailyStreak = 5;
  static const int xpPerWeeklyStreak = 20; // 7-day streak bonus
  static const int xpPerChallengeComplete = 25;

  /// Streak milestones
  static const int weeklyStreakDays = 7;
  static const int monthlyStreakDays = 30;

  /// Level calculation
  /// Formula: level = floor((-1 + sqrt(1 + 8*xp/100))/2) + 1
  /// This creates a quadratic progression where each level requires more XP
  static int calculateLevel(int totalXp) {
    if (totalXp < 0) return 1;
    final level = ((-1 + sqrt(1 + 8 * totalXp / 100)) / 2).floor() + 1;
    return max(1, level);
  }

  /// Calculate XP required for a specific level
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    final n = level - 1;
    return ((n * (n + 1)) / 2 * 100).floor();
  }

  /// Calculate XP needed to reach next level
  static int xpToNextLevel(int currentXp) {
    final currentLevel = calculateLevel(currentXp);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return nextLevelXp - currentXp;
  }

  /// Calculate XP progress percentage in current level
  static double levelProgress(int currentXp) {
    final currentLevel = calculateLevel(currentXp);
    final currentLevelXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final levelRange = nextLevelXp - currentLevelXp;

    if (levelRange == 0) return 1.0;

    final progress = (currentXp - currentLevelXp) / levelRange;
    return progress.clamp(0.0, 1.0);
  }

  /// Quiz passing threshold (80%)
  static const double quizPassThreshold = 0.8;

  /// Quiz perfect threshold (100%)
  static const double quizPerfectThreshold = 1.0;

  /// Calculate XP for quiz based on score
  static int calculateQuizXp(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;

    final score = correctAnswers / totalQuestions;

    if (score >= quizPerfectThreshold) {
      return xpPerQuizPerfect;
    } else if (score >= quizPassThreshold) {
      return xpPerQuizPass;
    } else {
      return xpPerQuizAttempt;
    }
  }
}
