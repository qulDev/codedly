import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/lessons/domain/entities/lesson.dart';
import 'package:codedly/features/lessons/domain/repositories/lessons_repository.dart';

/// Use case for getting lessons by module ID.
@lazySingleton
class GetLessons implements UseCase<List<Lesson>, GetLessonsParams> {
  final LessonsRepository repository;

  GetLessons(this.repository);

  @override
  Future<Either<Failure, List<Lesson>>> call(GetLessonsParams params) async {
    return await repository.getLessonsByModule(params.moduleId);
  }
}

/// Parameters for [GetLessons] use case.
class GetLessonsParams extends Equatable {
  final String moduleId;

  const GetLessonsParams({required this.moduleId});

  @override
  List<Object?> get props => [moduleId];
}
