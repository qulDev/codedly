import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out
@injectable
class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.signOut();
  }
}
