import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/quizzes/domain/repositories/quizzes_repository.dart';

/// Use case for completing a quiz and awarding XP.
@lazySingleton
class CompleteQuiz implements UseCase<void, CompleteQuizParams> {
  final QuizzesRepository repository;

  CompleteQuiz(this.repository);

  @override
  Future<Either<Failure, void>> call(CompleteQuizParams params) async {
    return await repository.completeQuiz(params.quizId, params.xpReward);
  }
}

/// Parameters for [CompleteQuiz] use case.
class CompleteQuizParams extends Equatable {
  final String quizId;
  final int xpReward;

  const CompleteQuizParams({
    required this.quizId,
    required this.xpReward,
  });

  @override
  List<Object?> get props => [quizId, xpReward];
}
