import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/lessons/domain/entities/module.dart';
import 'package:codedly/features/lessons/domain/entities/lesson.dart';
import 'package:codedly/features/lessons/domain/entities/lesson_hint.dart';

/// Repository contract for lessons and modules.
abstract class LessonsRepository {
  /// Gets all published modules with user progress.
  ///
  /// Returns [Right] with list of [Module] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<Module>>> getModules();

  /// Gets a specific module by ID.
  ///
  /// Returns [Right] with [Module] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, Module>> getModuleById(String moduleId);

  /// Gets all lessons for a specific module with user progress.
  ///
  /// Returns [Right] with list of [Lesson] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<Lesson>>> getLessonsByModule(String moduleId);

  /// Gets a specific lesson by ID.
  ///
  /// Returns [Right] with [Lesson] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, Lesson>> getLessonById(String lessonId);

  /// Gets hints for a specific lesson.
  ///
  /// Returns [Right] with list of [LessonHint] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<LessonHint>>> getHintsByLesson(String lessonId);

  /// Completes a lesson and awards XP.
  ///
  /// [lessonId] is the ID of the lesson to complete.
  /// Returns [Right] with success message on completion.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> completeLesson(String lessonId);

  /// Validates user code against expected output.
  ///
  /// [lessonId] is the lesson being validated.
  /// [userCode] is the code written by the user.
  /// Returns [Right] with true if validation passes, false otherwise.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, bool>> validateLessonCode(
    String lessonId,
    String userCode,
  );
}
