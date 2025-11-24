import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';

/// Repository contract for fetching leaderboard data.
abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    int limit = 50,
  });
}
