import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';
import 'package:codedly/features/quizzes/domain/repositories/quizzes_repository.dart';

/// Use case for getting quizzes by module ID.
@lazySingleton
class GetQuizzesByModule implements UseCase<List<Quizzes>, GetQuizzesByModuleParams> {
  final QuizzesRepository repository;

  GetQuizzesByModule(this.repository);

  @override
  Future<Either<Failure, List<Quizzes>>> call(GetQuizzesByModuleParams params) async {
    return await repository.getQuizzesByModule(params.moduleId);
  }
}

/// Parameters for [GetQuizzesByModule] use case.
class GetQuizzesByModuleParams extends Equatable {
  final String moduleId;

  const GetQuizzesByModuleParams({required this.moduleId});

  @override
  List<Object?> get props => [moduleId];
}
