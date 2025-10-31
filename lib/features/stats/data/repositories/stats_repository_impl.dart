import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/network/network_info.dart';
import 'package:codedly/features/stats/data/datasources/stats_remote_data_source.dart';
import 'package:codedly/features/stats/domain/entities/user_stats.dart';
import 'package:codedly/features/stats/domain/repositories/stats_repository.dart';

/// Implementation of [StatsRepository].
@LazySingleton(as: StatsRepository)
class StatsRepositoryImpl implements StatsRepository {
  final StatsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StatsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserStats>> getUserStats() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await remoteDataSource.getUserStats();
      return Right(stats);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserStats>> addXp(int xpToAdd) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await remoteDataSource.addXp(xpToAdd);
      return Right(stats);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserStats>> updateStreak() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await remoteDataSource.updateStreak();
      return Right(stats);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserStats>> incrementLessonsCompleted() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await remoteDataSource.incrementLessonsCompleted();
      return Right(stats);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserStats>> incrementQuizzesCompleted() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final stats = await remoteDataSource.incrementQuizzesCompleted();
      return Right(stats);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
