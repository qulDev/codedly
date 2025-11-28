import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart' hide Module;
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/network/network_info.dart';

import 'package:codedly/features/quizzes/data/datasources/quizzes_remote_data_source.dart';
import 'package:codedly/features/quizzes/domain/entities/module.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';
import 'package:codedly/features/quizzes/domain/repositories/quizzes_repository.dart';

@LazySingleton(as: QuizzesRepository)
class QuizzesRepositoryImpl implements QuizzesRepository {
  final QuizzesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  QuizzesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // ---------------------------
  // MODULES
  // ---------------------------
  @override
   Future<Either<Failure, List<Module>>> getModules() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final modules = await remoteDataSource.getModules();
      return Right(modules);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Module>> getModuleById(String moduleId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final module = await remoteDataSource.getModuleById(moduleId);
      return Right(module);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ---------------------------
  // QUIZZES
  // ---------------------------
  @override
  Future<Either<Failure, List<Quizzes>>> getQuizzesByModule(
    String moduleId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final quizzes = await remoteDataSource.getQuizzesByModule(moduleId);
      return Right(quizzes);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Quizzes>> getQuizById(String quizId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final quiz = await remoteDataSource.getQuizById(quizId);
      return Right(quiz);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ---------------------------
  // QUESTIONS
  // ---------------------------
  @override
  Future<Either<Failure, List<QuizOption>>> getQuestionsByQuiz(
    String quizId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final questions = await remoteDataSource.getQuestionsByQuiz(quizId);
      return Right(questions);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ---------------------------
  // COMPLETING QUIZ + XP
  // ---------------------------
  @override
  Future<Either<Failure, void>> completeQuiz(
    String quizId,
    int xpReward,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.completeQuiz(quizId, xpReward);
      return const Right(null);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
