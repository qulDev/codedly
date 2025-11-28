import 'package:codedly/features/quizzes/domain/usecases/get_modules.dart';
import 'package:codedly/features/quizzes/domain/entities/module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:codedly/core/di/injection.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/quizzes/domain/usecases/get_quizzes.dart';
import 'package:codedly/features/quizzes/domain/usecases/complete_quizzes.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_state.dart';
import 'package:codedly/features/stats/presentation/providers/stats_provider.dart';

/// Notifier for quizzes and modules state.
class QuizzesNotifier extends StateNotifier<QuizzesState> {
  final GetModules getModulesUseCase;
  final GetQuizzesByModule getQuizzesUseCase;
  final CompleteQuiz completeQuizUseCase;
  final Ref _ref;

  QuizzesNotifier({
    required this.getModulesUseCase,
    required this.getQuizzesUseCase,
    required this.completeQuizUseCase,
    required Ref ref,
  })  : _ref = ref,
        super(const QuizzesState()) {
    loadModules();
  }

  /// Loads all published modules.
  Future<void> loadModules() async {
    state = state.copyWith(status: QuizzesStatus.loading);

    final result = await getModulesUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: QuizzesStatus.error,
        errorMessage: failure.message,
      ),
      (modules) => state = state.copyWith(
        status: QuizzesStatus.loaded,
        modules: modules as List<Module>?,
      ),
    );
  }

  /// Loads quizzes for a specific module.
  Future<void> loadQuizzes(String moduleId) async {
    state = state.copyWith(status: QuizzesStatus.loading);

    final result = await getQuizzesUseCase(
      GetQuizzesByModuleParams(moduleId: moduleId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: QuizzesStatus.error,
        errorMessage: failure.message,
      ),
      (quizzes) => state = state.copyWith(
        status: QuizzesStatus.loaded,
        quizzes: quizzes,
      ),
    );
  }

  /// Sets the current quiz being viewed.
  void setCurrentQuiz(int index) {
    if (index >= 0 && index < state.quizzes.length) {
      state = state.copyWith(currentQuiz: state.quizzes[index]);
    }
  }

  /// Completes the current quiz.
  Future<void> completeCurrentQuiz() async {
    if (state.currentQuiz == null) return;

    state = state.copyWith(status: QuizzesStatus.completing);

    final result = await completeQuizUseCase(
      CompleteQuizParams(
        quizId: state.currentQuiz!.id,
        xpReward: state.currentQuiz!.xpReward,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: QuizzesStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        // Update the quiz as completed
        final updatedQuizzes = state.quizzes.map((quiz) {
          if (quiz.id == state.currentQuiz!.id) {
            return quiz.copyWith(isCompleted: true);
          }
          return quiz;
        }).toList();

        final updatedModules = state.modules.map((module) {
          if (module.id == state.currentQuiz!.moduleId) {
            final newCompleted = module.quizzesCompleted + 1;
            final cappedCompleted = module.totalQuizzes == 0
                ? newCompleted
                : newCompleted > module.totalQuizzes
                    ? module.totalQuizzes
                    : newCompleted;
            return module.copyWith(quizzesCompleted: cappedCompleted);
          }
          return module;
        }).toList();

        state = state.copyWith(
          status: QuizzesStatus.completed,
          quizzes: updatedQuizzes,
          modules: updatedModules,
          currentQuiz: state.currentQuiz!.copyWith(isCompleted: true),
        );

        // Refresh aggregated stats so Profile/Home progress stays in sync
        unawaited(_ref.read(statsProvider.notifier).refreshStats());
      },
    );
  }

  /// Refreshes modules.
  Future<void> refreshModules() async {
    await loadModules();
  }
}

/// Provider for quizzes and modules.
final quizzesProvider = StateNotifierProvider<QuizzesNotifier, QuizzesState>(
  (ref) {
    return QuizzesNotifier(
      getModulesUseCase: getIt<GetModules>(),
      getQuizzesUseCase: getIt<GetQuizzesByModule>(),
      completeQuizUseCase: getIt<CompleteQuiz>(),
      ref: ref,
    );
  },
);
