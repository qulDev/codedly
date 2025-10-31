import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/stats/domain/entities/user_stats.dart';

/// Repository contract for user statistics.
abstract class StatsRepository {
  /// Gets the current user's statistics.
  ///
  /// Returns [Right] with [UserStats] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserStats>> getUserStats();

  /// Updates the user's XP and recalculates level.
  ///
  /// [xpToAdd] is the amount of XP to add to the current total.
  /// Returns [Right] with updated [UserStats] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserStats>> addXp(int xpToAdd);

  /// Updates the user's streak count.
  ///
  /// Returns [Right] with updated [UserStats] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserStats>> updateStreak();

  /// Increments the lessons completed counter.
  ///
  /// Returns [Right] with updated [UserStats] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserStats>> incrementLessonsCompleted();

  /// Increments the quizzes completed counter.
  ///
  /// Returns [Right] with updated [UserStats] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, UserStats>> incrementQuizzesCompleted();
}
