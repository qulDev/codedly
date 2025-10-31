import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/lessons/domain/repositories/lessons_repository.dart';

/// Use case for completing a lesson.
@lazySingleton
class CompleteLesson implements UseCase<void, CompleteLessonParams> {
  final LessonsRepository repository;

  CompleteLesson(this.repository);

  @override
  Future<Either<Failure, void>> call(CompleteLessonParams params) async {
    return await repository.completeLesson(params.lessonId);
  }
}

/// Parameters for [CompleteLesson] use case.
class CompleteLessonParams extends Equatable {
  final String lessonId;

  const CompleteLessonParams({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}
