import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart' hide Module;
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/lessons/domain/entities/module.dart';
import 'package:codedly/features/lessons/domain/repositories/lessons_repository.dart';

/// Use case for getting all published modules.
@lazySingleton
class GetModules implements UseCase<List<Module>, NoParams> {
  final LessonsRepository repository;

  GetModules(this.repository);

  @override
  Future<Either<Failure, List<Module>>> call(NoParams params) async {
    return await repository.getModules();
  }
}
