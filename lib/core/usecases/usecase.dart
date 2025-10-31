import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';

/// Base class for use cases.
///
/// [Type] is the return type.
/// [Params] is the parameters type. Use [NoParams] if no parameters are needed.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when a use case doesn't require any parameters.
class NoParams {}
