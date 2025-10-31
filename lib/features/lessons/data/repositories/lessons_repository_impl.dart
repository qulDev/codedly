import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart' hide Module;
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/network/network_info.dart';
import 'package:codedly/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:codedly/features/lessons/domain/entities/module.dart';
import 'package:codedly/features/lessons/domain/entities/lesson.dart';
import 'package:codedly/features/lessons/domain/entities/lesson_hint.dart';
import 'package:codedly/features/lessons/domain/repositories/lessons_repository.dart';

/// Implementation of [LessonsRepository].
@LazySingleton(as: LessonsRepository)
class LessonsRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LessonsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

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

  @override
  Future<Either<Failure, List<Lesson>>> getLessonsByModule(
    String moduleId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final lessons = await remoteDataSource.getLessonsByModule(moduleId);
      return Right(lessons);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Lesson>> getLessonById(String lessonId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final lesson = await remoteDataSource.getLessonById(lessonId);
      return Right(lesson);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<LessonHint>>> getHintsByLesson(
    String lessonId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final hints = await remoteDataSource.getHintsByLesson(lessonId);
      return Right(hints);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> completeLesson(String lessonId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.completeLesson(lessonId);
      return const Right(null);
    } on app_exceptions.ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> validateLessonCode(
    String lessonId,
    String userCode,
  ) async {
    // TODO: Implement code validation
    // For now, return true as a placeholder
    // This will need a Python execution backend
    return const Right(true);
  }
}
