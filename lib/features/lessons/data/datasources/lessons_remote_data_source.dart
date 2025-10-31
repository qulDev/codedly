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
  /// Calls the Supabase RPC function `complete_lesson`.
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

      // Call RPC function to complete lesson
      await _supabaseClient.rpc(
        'complete_lesson',
        params: {
          'user_id_param': userId,
          'lesson_id_param': lessonId,
          'xp_earned': xpReward,
        },
      );
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }
}
