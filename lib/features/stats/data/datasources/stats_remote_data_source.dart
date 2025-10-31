import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/features/stats/data/models/user_stats_model.dart';

/// Remote data source for user statistics.
///
/// Handles communication with Supabase for stats operations.
@lazySingleton
class StatsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  StatsRemoteDataSource(this._supabaseClient);

  /// Gets the current user's statistics from the database.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> getUserStats() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .single();

      return UserStatsModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Updates the user's stats in the database.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> updateStats(Map<String, dynamic> updates) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      final response = await _supabaseClient
          .from('user_stats')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return UserStatsModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Adds XP to the user's total and recalculates level.
  ///
  /// Calls the Supabase RPC function to handle level calculation.
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> addXp(int xpToAdd) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      // Call Supabase RPC function that adds XP and recalculates level
      await _supabaseClient.rpc(
        'add_xp',
        params: {'user_id_param': userId, 'xp_to_add': xpToAdd},
      );

      // Fetch updated stats
      return await getUserStats();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Updates the user's streak count.
  ///
  /// Calls the Supabase RPC function to handle streak logic.
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> updateStreak() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      // Call Supabase RPC function that updates streak
      await _supabaseClient.rpc(
        'update_streak',
        params: {'user_id_param': userId},
      );

      // Fetch updated stats
      return await getUserStats();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Increments the lessons completed counter.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> incrementLessonsCompleted() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      final currentStats = await getUserStats();
      final updates = {
        'lessons_completed': currentStats.lessonsCompleted + 1,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await updateStats(updates);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Increments the quizzes completed counter.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<UserStatsModel> incrementQuizzesCompleted() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      final currentStats = await getUserStats();
      final updates = {
        'quizzes_completed': currentStats.quizzesCompleted + 1,
        'updated_at': DateTime.now().toIso8601String(),
      };

      return await updateStats(updates);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }
}
