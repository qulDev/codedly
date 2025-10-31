import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/entities/user.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in with email and password
@injectable
class SignInWithEmail {
  final AuthRepository _repository;

  SignInWithEmail(this._repository);

  Future<Either<Failure, User>> call(SignInParams params) async {
    return await _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
