import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/entities/user.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with Google OAuth
@lazySingleton
class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<Either<Failure, User>> call() async {
    return await _repository.signInWithGoogle();
  }
}
