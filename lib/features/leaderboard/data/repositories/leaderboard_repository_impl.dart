import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/network/network_info.dart';
import 'package:codedly/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:codedly/features/leaderboard/domain/repositories/leaderboard_repository.dart';

@LazySingleton(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LeaderboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final entries = await remoteDataSource.fetchLeaderboard(limit: limit);
      return Right(entries);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
