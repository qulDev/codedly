import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/entities/user.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting current authenticated user
@injectable
class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Future<Either<Failure, User?>> call() async {
    return await _repository.getCurrentUser();
  }
}
