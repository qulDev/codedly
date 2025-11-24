import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:codedly/features/leaderboard/domain/repositories/leaderboard_repository.dart';

@lazySingleton
class GetLeaderboard
    implements UseCase<List<LeaderboardEntry>, GetLeaderboardParams> {
  final LeaderboardRepository repository;

  GetLeaderboard(this.repository);

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> call(
    GetLeaderboardParams params,
  ) {
    return repository.getLeaderboard(limit: params.limit);
  }
}

class GetLeaderboardParams {
  final int limit;

  const GetLeaderboardParams({this.limit = 50});
}
