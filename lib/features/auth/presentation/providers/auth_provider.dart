import 'package:codedly/features/auth/domain/entities/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/di/injection.dart';
import 'package:codedly/features/auth/domain/usecases/get_current_user.dart';
import 'package:codedly/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:codedly/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:codedly/features/auth/domain/usecases/sign_out.dart';
import 'package:codedly/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:codedly/features/auth/presentation/providers/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
/// Auth state notifier provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getCurrentUser: getIt<GetCurrentUser>(),
    signInWithEmail: getIt<SignInWithEmail>(),
    signInWithGoogle: getIt<SignInWithGoogle>(),
    signUpWithEmail: getIt<SignUpWithEmail>(),
    signOut: getIt<SignOut>(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final GetCurrentUser _getCurrentUser;
  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;

  AuthNotifier({
    required GetCurrentUser getCurrentUser,
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignUpWithEmail signUpWithEmail,
    required SignOut signOut,
  }) : _getCurrentUser = getCurrentUser,
       _signInWithEmail = signInWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signUpWithEmail = signUpWithEmail,
       _signOut = signOut,
       super(const AuthState.initial()) {
    checkAuthStatus();
     // Listener untuk menangani Google OAuth setelah redirect
      supa.Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final session = data.session;
    if (session != null) {
      await loadUserFromSupabase(); // update state ke authenticated
    } else {
      state = const AuthState.unauthenticated();
    }
  });
  }

  Future<void> loadUserFromSupabase() async {
  final supaUser = supa.Supabase.instance.client.auth.currentUser;
  if (supaUser == null) {
    state = const AuthState.unauthenticated();
    return;
  }

  final meta = supaUser.userMetadata ?? {};

  final createdAt = () {
    try {
      return DateTime.parse(meta['created_at'] ?? supaUser.createdAt ?? DateTime.now().toIso8601String());
    } catch (_) {
      return DateTime.now();
    }
  }();

  final user = User(
    id: supaUser.id,
    email: supaUser.email ?? '',
    displayName: meta['full_name'] ?? meta['name'] ?? meta['user_name'],
    languagePreference: meta['language_preference'] ?? "en",
    onboardingCompleted: meta['onboarding_completed'] ?? false,
    createdAt: createdAt,
  );

  state = AuthState.authenticated(user);
}


  /// Check current authentication status
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final result = await _getCurrentUser();

    result.fold((failure) => state = const AuthState.unauthenticated(), (user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  /// Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    state = const AuthState.loading();

    final result = await _signInWithEmail(
      SignInParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String languagePreference,
  }) async {
    state = const AuthState.loading();

    final result = await _signUpWithEmail(
      SignUpParams(
        email: email,
        password: password,
        displayName: displayName,
        languagePreference: languagePreference,
      ),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign in with Google OAuth
  Future<void> signInWithGoogle() async {
    state = const AuthState.loading();

    final result = await _signInWithGoogle();

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (user) => state = AuthState.authenticated(user),
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    final result = await _signOut();

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (_) => state = const AuthState.unauthenticated(),
    );
  }
}