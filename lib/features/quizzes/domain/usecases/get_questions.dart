import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';
import 'package:codedly/features/quizzes/domain/repositories/quizzes_repository.dart';

@lazySingleton
class GetQuestionsByQuiz
    implements UseCase<List<QuizQuestion>, GetQuestionsByQuizParams> {
  final QuizzesRepository repository;

  GetQuestionsByQuiz(this.repository);

  @override
  Future<Either<Failure, List<QuizQuestion>>> call(
    GetQuestionsByQuizParams params,
  ) async {
    return await repository.getQuestionsByQuiz(params.quizId);
  }
}

class GetQuestionsByQuizParams extends Equatable {
  final String quizId;

  const GetQuestionsByQuizParams({required this.quizId});

  @override
  List<Object?> get props => [quizId];
}
