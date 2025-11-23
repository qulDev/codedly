import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/features/lessons/data/models/module_model.dart';
import 'package:codedly/features/lessons/data/models/lesson_model.dart';
import 'package:codedly/features/lessons/data/models/lesson_hint_model.dart';

/// Remote data source for lessons and modules.
///
/// Handles communication with Supabase for lesson operations.
@lazySingleton
class LessonsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  LessonsRemoteDataSource(this._supabaseClient);

  /// Gets all published modules with lesson counts and user progress.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<List<ModuleModel>> getModules() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      // Get all published modules
      final modulesResponse = await _supabaseClient
          .from('modules')
          .select()
          .eq('is_published', true)
          .order('order_index');

      final modules = <ModuleModel>[];

      for (final moduleData in modulesResponse as List) {
        // Count total lessons in this module
        final totalLessonsResponse = await _supabaseClient
            .from('lessons')
            .select('id')
            .eq('module_id', moduleData['id'])
            .eq('is_published', true);

        final totalLessons = (totalLessonsResponse as List).length;

        // Count completed lessons for this user
        final completedLessonsResponse = await _supabaseClient
            .from('user_progress')
            .select('content_id')
            .eq('user_id', userId)
            .eq('content_type', 'lesson')
            .eq('is_completed', true);

        // Get lesson IDs for this module to filter completed count
        final moduleLessonIds = (totalLessonsResponse as List)
            .map((l) => l['id'] as String)
            .toSet();

        // Count only completed lessons from this module
        final completedInThisModule = (completedLessonsResponse as List)
            .where((p) => moduleLessonIds.contains(p['content_id'] as String))
            .length;

        modules.add(
          ModuleModel.fromJson({
            ...moduleData,
            'total_lessons': totalLessons,
            'lessons_completed': completedInThisModule,
          }),
        );
      }

      return modules;
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Gets a specific module by ID.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<ModuleModel> getModuleById(String moduleId) async {
    try {
      final response = await _supabaseClient
          .from('modules')
          .select()
          .eq('id', moduleId)
          .single();

      return ModuleModel.fromJson(response);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Gets all lessons for a specific module with user progress.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<List<LessonModel>> getLessonsByModule(String moduleId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      // Get all lessons for the module
      final lessonsResponse = await _supabaseClient
          .from('lessons')
          .select()
          .eq('module_id', moduleId)
          .eq('is_published', true)
          .order('order_index');

      // Get user progress for these lessons
      final progressResponse = await _supabaseClient
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('content_type', 'lesson');

      final progressMap = {
        for (var p in progressResponse as List)
          p['content_id'] as String: p['is_completed'] as bool,
      };

      final lessons = (lessonsResponse as List).map((lessonData) {
        final lessonId = lessonData['id'] as String;
        final isCompleted = progressMap[lessonId] ?? false;

        return LessonModel.fromJson({
          ...lessonData,
          'is_completed': isCompleted,
        });
      }).toList();

      return lessons;
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Gets a specific lesson by ID.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<LessonModel> getLessonById(String lessonId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      final lessonResponse = await _supabaseClient
          .from('lessons')
          .select()
          .eq('id', lessonId)
          .single();

      // Check if user has completed this lesson
      final progressResponse = await _supabaseClient
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('content_type', 'lesson')
          .eq('content_id', lessonId)
          .maybeSingle();

      final isCompleted =
          progressResponse != null &&
          (progressResponse['is_completed'] as bool? ?? false);

      return LessonModel.fromJson({
        ...lessonResponse,
        'is_completed': isCompleted,
      });
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Gets hints for a specific lesson.
  ///
  /// Throws [ServerException] if the operation fails.
  Future<List<LessonHintModel>> getHintsByLesson(String lessonId) async {
    try {
      final response = await _supabaseClient
          .from('lesson_hints')
          .select()
          .eq('lesson_id', lessonId)
          .order('order_index');

      return (response as List)
          .map((json) => LessonHintModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  /// Completes a lesson and awards XP.
  ///
  /// Persists the completion across `user_progress`, `xp_records`, and
  /// `user_stats` so the profile overview stays in sync even if the
  /// backend RPCs have not been deployed yet.
  /// Throws [ServerException] if the operation fails.
  Future<void> completeLesson(String lessonId) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw app_exceptions.ServerException('User not authenticated');
      }

      // Get lesson XP reward
      final lessonResponse = await _supabaseClient
          .from('lessons')
          .select('xp_reward')
          .eq('id', lessonId)
          .single();

      final xpReward = lessonResponse['xp_reward'] as int;

      final now = DateTime.now().toUtc();

      final existingProgress = await _supabaseClient
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('content_type', 'lesson')
          .eq('content_id', lessonId)
          .maybeSingle();

      final attempts = (existingProgress?['attempts_count'] as int? ?? 0) + 1;
      final alreadyCompleted =
          existingProgress?['is_completed'] as bool? ?? false;

      if (existingProgress == null) {
        await _supabaseClient.from('user_progress').insert({
          'user_id': userId,
          'content_type': 'lesson',
          'content_id': lessonId,
          'is_completed': true,
          'xp_earned': xpReward,
          'attempts_count': attempts,
          'first_attempted_at': now.toIso8601String(),
          'completed_at': now.toIso8601String(),
        });
      } else {
        await _supabaseClient
            .from('user_progress')
            .update({
              'is_completed': true,
              'xp_earned': max(
                existingProgress['xp_earned'] as int? ?? 0,
                xpReward,
              ),
              'attempts_count': attempts,
              'completed_at': now.toIso8601String(),
              if (existingProgress['first_attempted_at'] == null)
                'first_attempted_at': now.toIso8601String(),
            })
            .eq('id', existingProgress['id']);
      }

      if (!alreadyCompleted) {
        await _insertXpRecord(userId, lessonId, xpReward);
        await _updateStatsAfterLesson(userId, xpReward, now);
      }
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  Future<void> _insertXpRecord(
    String userId,
    String lessonId,
    int xpReward,
  ) async {
    if (xpReward <= 0) return;

    await _supabaseClient.from('xp_records').insert({
      'user_id': userId,
      'xp_amount': xpReward,
      'reason': 'Lesson completed',
      'content_type': 'lesson',
      'content_id': lessonId,
    });
  }

  Future<void> _updateStatsAfterLesson(
    String userId,
    int xpReward,
    DateTime now,
  ) async {
    final statsResponse = await _supabaseClient
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .single();

    final currentXp = statsResponse['total_xp'] as int? ?? 0;
    final totalXp = currentXp + xpReward;
    final currentLessons = statsResponse['lessons_completed'] as int? ?? 0;
    final streak = statsResponse['streak_count'] as int? ?? 0;
    final lastActivityIso = statsResponse['last_activity_date'] as String?;

    final normalizedNow = DateTime.utc(now.year, now.month, now.day);
    final nextStreak = _calculateNextStreak(
      lastActivityIso,
      streak,
      normalizedNow,
    );

    await _supabaseClient
        .from('user_stats')
        .update({
          'total_xp': totalXp,
          'current_level': _calculateLevel(totalXp),
          'streak_count': nextStreak,
          'last_activity_date': normalizedNow.toIso8601String(),
          'lessons_completed': currentLessons + 1,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId);
  }

  int _calculateNextStreak(
    String? lastActivityIso,
    int currentStreak,
    DateTime today,
  ) {
    if (lastActivityIso == null) {
      return 1;
    }

    final lastDate = DateTime.tryParse(lastActivityIso)?.toUtc();
    if (lastDate == null) {
      return 1;
    }

    final lastDay = DateTime.utc(lastDate.year, lastDate.month, lastDate.day);
    final diffDays = today.difference(lastDay).inDays;

    if (diffDays == 0) {
      return currentStreak;
    } else if (diffDays == 1) {
      return currentStreak + 1;
    } else {
      return 1;
    }
  }

  int _calculateLevel(int totalXp) {
    final xpAsDouble = totalXp.toDouble();
    final level = ((sqrt(1 + 8 * xpAsDouble / 100) - 1) / 2).floor() + 1;
    return max(level, 1);
  }
}
