import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/entities/user.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing up with email and password
@injectable
class SignUpWithEmail {
  final AuthRepository _repository;

  SignUpWithEmail(this._repository);

  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      languagePreference: params.languagePreference,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String languagePreference;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    required this.languagePreference,
  });

  @override
  List<Object> get props => [email, password, displayName, languagePreference];
}
