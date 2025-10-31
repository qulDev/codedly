import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/stats/domain/entities/user_stats.dart';
import 'package:codedly/features/stats/domain/repositories/stats_repository.dart';

/// Use case for getting the current user's statistics.
@lazySingleton
class GetUserStats implements UseCase<UserStats, NoParams> {
  final StatsRepository repository;

  GetUserStats(this.repository);

  @override
  Future<Either<Failure, UserStats>> call(NoParams params) async {
    return await repository.getUserStats();
  }
}
