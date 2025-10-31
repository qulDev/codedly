import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:codedly/core/errors/exceptions.dart';
import 'package:codedly/features/auth/data/models/user_model.dart';

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String languagePreference,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> updateProfile({
    String? displayName,
    String? languagePreference,
    bool? onboardingCompleted,
  });

  Future<void> resetPassword({required String email});

  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed');
      }

      // Fetch user profile
      final profileData = await _client
          .from('user_profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(profileData);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String languagePreference,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed');
      }

      // Create user profile
      final profileData = {
        'id': response.user!.id,
        'email': email,
        'display_name': displayName,
        'language_preference': languagePreference,
        'onboarding_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_profiles').insert(profileData);

      return UserModel.fromJson(profileData);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        supabase.OAuthProvider.google,
      );

      if (!response) {
        throw const AuthException('Google sign in failed');
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(seconds: 1));

      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('Google sign in failed');
      }

      // Check if profile exists, create if not
      final existingProfile = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Create new profile
        final profileData = {
          'id': user.id,
          'email': user.email!,
          'display_name': user.userMetadata?['full_name'] as String?,
          'language_preference': 'en',
          'onboarding_completed': false,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _client.from('user_profiles').insert(profileData);
        return UserModel.fromJson(profileData);
      }

      return UserModel.fromJson(existingProfile);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profileData = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profileData);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? languagePreference,
    bool? onboardingCompleted,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const AuthException('No authenticated user');
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (displayName != null) updates['display_name'] = displayName;
      if (languagePreference != null) {
        updates['language_preference'] = languagePreference;
      }
      if (onboardingCompleted != null) {
        updates['onboarding_completed'] = onboardingCompleted;
      }

      await _client.from('user_profiles').update(updates).eq('id', user.id);

      final profileData = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profileData);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on supabase.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      try {
        final profileData = await _client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(profileData);
      } catch (e) {
        return null;
      }
    });
  }
}
