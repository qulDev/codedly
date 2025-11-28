import 'dart:math';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/features/quizzes/data/models/module_model.dart';
import 'package:codedly/features/quizzes/data/models/quizzes_model.dart';
import 'package:codedly/features/quizzes/data/models/quizzes_option_model.dart';

@lazySingleton
class QuizzesRemoteDataSource {
  final SupabaseClient _supabase;

  QuizzesRemoteDataSource(this._supabase);

  // ---------------------------
  // MODULES
  // ---------------------------
  Future<List<ModuleModel>> getModules() async {
    try {
      final userId = _requireUserId();

      final modules = await _supabase
          .from('modules')
          .select()
          .eq('is_published', true)
          .order('order_index');

      if (modules.isEmpty) return [];

      final moduleIds = modules.map((e) => e['id']).toList();

      // Ambil quiz count per module tanpa loop query
      final quizzes = await _supabase
          .from('quizzes')
          .select('id')
          .eq('is_published', true)
          .inFilter('module_id', moduleIds);

      // Ambil completed quizzes dalam satu query
      final completed = await _supabase
          .from('user_progress')
          .select('content_id')
          .eq('user_id', userId)
          .eq('content_type', 'quiz')
          .eq('is_completed', true);

      final completedSet = completed.map((e) => e['content_id'] as String).toSet();

      return modules.map((m) {
        final moduleId = m['id'];
        final moduleQuizzes =
            quizzes.where((q) => q['module_id'] == moduleId).map((q) => q['id']).toList();

        return ModuleModel.fromJson({
          ...m,
          'total_quiz': moduleQuizzes.length,
          'quiz_completed': moduleQuizzes.where(completedSet.contains).length,
        });
      }).toList();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  Future<ModuleModel> getModuleById(String moduleId) async {
    try {
      final res = await _supabase.from('modules').select().eq('id', moduleId).single();
      return ModuleModel.fromJson(res);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  // ---------------------------
  // QUIZZES
  // ---------------------------
  Future<List<QuizzesModel>> getQuizzesByModule(String moduleId) async {
    try {
      final userId = _requireUserId();
      final quizzes = await _supabase
          .from('quizzes')
          .select()
          .eq('module_id', moduleId)
          .eq('is_published', true)
          .order('order_index');

      if (quizzes.isEmpty) return [];

      final ids = quizzes.map((q) => q['id']).toList();

      final progress = await _supabase
          .from('user_progress')
          .select('content_id,is_completed')
          .eq('user_id', userId)
          .eq('content_type', 'quiz')
          .inFilter('content_id', ids);

      final completedMap = {for (var p in progress) p['content_id']: p['is_completed'] ?? false};

      return quizzes.map((quiz) {
        return QuizzesModel.fromJson({
          ...quiz,
          'is_completed': completedMap[quiz['id']] ?? false,
        });
      }).toList();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  Future<QuizzesModel> getQuizById(String quizId) async {
    try {
      final userId = _requireUserId();

      final q = await _supabase.from('quizzes').select().eq('id', quizId).single();

      final progress = await _supabase
          .from('user_progress')
          .select('is_completed')
          .eq('user_id', userId)
          .eq('content_type', 'quiz')
          .eq('content_id', quizId)
          .maybeSingle();

      return QuizzesModel.fromJson({
        ...q,
        'is_completed': progress?['is_completed'] ?? false,
      });
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  // ---------------------------
  // QUESTIONS
  // ---------------------------
  Future<List<QuizOptionModel>> getQuestionsByQuiz(String quizId) async {
    try {
      final response = await _supabase
          .from('quiz_questions')
          .select()
          .eq('quiz_id', quizId)
          .order('order_index');

      return (response as List)
          .map((json) => QuizOptionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  // ---------------------------
  // COMPLETION + XP + STATS
  // ---------------------------
  Future<void> completeQuiz(String quizId, int xpReward) async {
    try {
      final userId = _requireUserId();
      final now = DateTime.now().toUtc();

      final existing = await _supabase
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('content_type', 'quiz')
          .eq('content_id', quizId)
          .maybeSingle();

      final attempts = (existing?['attempts_count'] ?? 0) + 1;
      final prevCompleted = existing?['is_completed'] ?? false;

      if (existing == null) {
        await _supabase.from('user_progress').insert({
          'user_id': userId,
          'content_type': 'quiz',
          'content_id': quizId,
          'is_completed': true,
          'xp_earned': xpReward,
          'attempts_count': attempts,
          'first_attempted_at': now.toIso8601String(),
          'completed_at': now.toIso8601String(),
        });
      } else {
        await _supabase
            .from('user_progress')
            .update({
              'is_completed': true,
              'xp_earned': max(existing['xp_earned'] ?? 0, xpReward),
              'attempts_count': attempts,
              'completed_at': now.toIso8601String(),
            })
            .eq('id', existing['id']);
      }

      if (!prevCompleted && xpReward > 0) {
        await _insertXpRecord(userId, quizId, xpReward);
        await _updateUserStats(userId, xpReward, now);
      }
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }

  Future<void> _insertXpRecord(String userId, String quizId, int xp) async {
    await _supabase.from('xp_records').insert({
      'user_id': userId,
      'xp_amount': xp,
      'reason': 'Quiz completed',
      'content_type': 'quiz',
      'content_id': quizId,
    });
  }

  Future<void> _updateUserStats(String userId, int xp, DateTime now) async {
    final stats = await _supabase.from('user_stats').select().eq('user_id', userId).maybeSingle();

    final today = DateTime.utc(now.year, now.month, now.day);
    final lastIso = stats?['last_activity_date'] as String?;
    final streak = stats?['streak_count'] ?? 0;
    final quizzesDone = stats?['quizzes_completed'] ?? 0;
    final oldXp = stats?['total_xp'] ?? 0;

    final nextStreak = _calculateNextStreak(lastIso, streak, today);
    final totalXp = oldXp + xp;

    if (stats != null) {
      await _supabase
          .from('user_stats')
          .update({
            'total_xp': totalXp,
            'current_level': _calculateLevel(totalXp),
            'streak_count': nextStreak,
            'last_activity_date': today.toIso8601String(),
            'quizzes_completed': quizzesDone + 1,
            'updated_at': now.toIso8601String(),
          })
          .eq('user_id', userId);
    } else {
      await _supabase.from('user_stats').insert({
        'user_id': userId,
        'total_xp': totalXp,
        'current_level': _calculateLevel(totalXp),
        'streak_count': nextStreak,
        'last_activity_date': today.toIso8601String(),
        'quizzes_completed': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    }
  }

  // ---------------------------
  // HELPERS
  // ---------------------------
  String _requireUserId() {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw app_exceptions.ServerException('User not authenticated');
    return id;
  }

  int _calculateNextStreak(String? lastIso, int currentStreak, DateTime today) {
    if (lastIso == null) return 1;
    final last = DateTime.tryParse(lastIso)?.toUtc();
    if (last == null) return 1;
    final diff = today.difference(DateTime.utc(last.year, last.month, last.day)).inDays;
    if (diff == 0) return currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  int _calculateLevel(int xp) {
    final lvl = ((sqrt(1 + 8 * xp / 100) - 1) / 2).floor() + 1;
    return max(lvl, 1);
  }
}
