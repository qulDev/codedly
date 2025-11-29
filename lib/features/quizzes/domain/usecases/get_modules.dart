import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart' hide Module;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/quizzes/domain/entities/module.dart';
import 'package:codedly/features/quizzes/domain/repositories/quizzes_repository.dart';

/// Use case for getting all published quiz modules.
@lazySingleton
class GetQuizModules implements UseCase<List<Module>, NoParams> {
  final QuizzesRepository repository;

  GetQuizModules(this.repository);

  @override
  Future<Either<Failure, List<Module>>> call(NoParams params) async {
    return await repository.getModules();
  }
}
