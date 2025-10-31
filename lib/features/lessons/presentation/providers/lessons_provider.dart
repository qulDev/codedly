import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/di/injection.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/lessons/domain/usecases/get_modules.dart';
import 'package:codedly/features/lessons/domain/usecases/get_lessons.dart';
import 'package:codedly/features/lessons/domain/usecases/complete_lesson.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_state.dart';

/// Notifier for lessons and modules state.
class LessonsNotifier extends StateNotifier<LessonsState> {
  final GetModules getModulesUseCase;
  final GetLessons getLessonsUseCase;
  final CompleteLesson completeLessonUseCase;

  LessonsNotifier({
    required this.getModulesUseCase,
    required this.getLessonsUseCase,
    required this.completeLessonUseCase,
  }) : super(const LessonsState()) {
    loadModules();
  }

  /// Loads all published modules.
  Future<void> loadModules() async {
    state = state.copyWith(status: LessonsStatus.loading);

    final result = await getModulesUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: LessonsStatus.error,
        errorMessage: failure.message,
      ),
      (modules) => state = state.copyWith(
        status: LessonsStatus.loaded,
        modules: modules,
      ),
    );
  }

  /// Loads lessons for a specific module.
  Future<void> loadLessons(String moduleId) async {
    state = state.copyWith(status: LessonsStatus.loading);

    final result = await getLessonsUseCase(
      GetLessonsParams(moduleId: moduleId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: LessonsStatus.error,
        errorMessage: failure.message,
      ),
      (lessons) => state = state.copyWith(
        status: LessonsStatus.loaded,
        lessons: lessons,
      ),
    );
  }

  /// Sets the current lesson being viewed.
  void setCurrentLesson(int index) {
    if (index >= 0 && index < state.lessons.length) {
      state = state.copyWith(currentLesson: state.lessons[index]);
    }
  }

  /// Completes the current lesson.
  Future<void> completeCurrentLesson() async {
    if (state.currentLesson == null) return;

    state = state.copyWith(status: LessonsStatus.completing);

    final result = await completeLessonUseCase(
      CompleteLessonParams(lessonId: state.currentLesson!.id),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: LessonsStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        // Update the lesson as completed
        final updatedLessons = state.lessons.map((lesson) {
          if (lesson.id == state.currentLesson!.id) {
            return lesson.copyWith(isCompleted: true);
          }
          return lesson;
        }).toList();

        state = state.copyWith(
          status: LessonsStatus.completed,
          lessons: updatedLessons,
          currentLesson: state.currentLesson!.copyWith(isCompleted: true),
        );
      },
    );
  }

  /// Refreshes modules.
  Future<void> refreshModules() async {
    await loadModules();
  }
}

/// Provider for lessons and modules.
final lessonsProvider = StateNotifierProvider<LessonsNotifier, LessonsState>((
  ref,
) {
  return LessonsNotifier(
    getModulesUseCase: getIt<GetModules>(),
    getLessonsUseCase: getIt<GetLessons>(),
    completeLessonUseCase: getIt<CompleteLesson>(),
  );
});
