import 'package:dartz/dartz.dart';
import 'package:codedly/core/errors/failures.dart';
import 'package:codedly/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String languagePreference,
  });

  /// Sign in with Google OAuth
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? languagePreference,
    bool? onboardingCompleted,
  });

  /// Reset password
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges;
}
