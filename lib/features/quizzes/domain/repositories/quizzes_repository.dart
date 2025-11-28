import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/quizzes/domain/entities/module.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';

/// Repository contract for quizzes and quiz modules.
abstract class QuizzesRepository {
  // ---------------------------
  // MODULES
  // ---------------------------

  /// Gets all published quiz modules with user progress.
  ///
  /// Returns [Right] with list of [Module] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<Module>>> getModules();

  /// Gets a specific quiz module by ID.
  ///
  /// Returns [Right] with [Module] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, Module>> getModuleById(String moduleId);

  // ---------------------------
  // QUIZZES
  // ---------------------------

  /// Gets all quizzes inside a module with user progress.
  ///
  /// Returns [Right] with list of [Quiz] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<Quizzes>>> getQuizzesByModule(String moduleId);

  /// Gets a specific quiz by ID.
  ///
  /// Returns [Right] with [Quiz] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, Quizzes>> getQuizById(String quizId);

  // ---------------------------
  // QUESTIONS
  // ---------------------------

  /// Gets all questions for a quiz.
  ///
  /// Returns [Right] with list of [QuizOption] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, List<QuizOption>>> getQuestionsByQuiz(String quizId);

  // ---------------------------
  // COMPLETE + REWARDS
  // ---------------------------

  /// Completes a quiz and awards XP to user.
  ///
  /// [quizId] — completed quiz.
  /// [xpReward] — XP reward given after completion.
  ///
  /// Returns [Right] on success.
  /// Returns [Left] with [Failure] on error.
  Future<Either<Failure, void>> completeQuiz(String quizId, int xpReward);
}
