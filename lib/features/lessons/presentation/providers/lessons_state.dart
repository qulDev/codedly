import 'package:equatable/equatable.dart';
import 'package:codedly/features/lessons/domain/entities/module.dart';
import 'package:codedly/features/lessons/domain/entities/lesson.dart';

/// State for modules and lessons.
class LessonsState extends Equatable {
  final LessonsStatus status;
  final List<Module> modules;
  final List<Lesson> lessons;
  final Lesson? currentLesson;
  final String? errorMessage;

  const LessonsState({
    this.status = LessonsStatus.initial,
    this.modules = const [],
    this.lessons = const [],
    this.currentLesson,
    this.errorMessage,
  });

  LessonsState copyWith({
    LessonsStatus? status,
    List<Module>? modules,
    List<Lesson>? lessons,
    Lesson? currentLesson,
    String? errorMessage,
    bool clearCurrentLesson = false,
  }) {
    return LessonsState(
      status: status ?? this.status,
      modules: modules ?? this.modules,
      lessons: lessons ?? this.lessons,
      currentLesson: clearCurrentLesson
          ? null
          : (currentLesson ?? this.currentLesson),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    modules,
    lessons,
    currentLesson,
    errorMessage,
  ];
}

/// Status values for [LessonsState].
enum LessonsStatus {
  /// Initial state, no data loaded yet.
  initial,

  /// Loading modules or lessons.
  loading,

  /// Data loaded successfully.
  loaded,

  /// Completing a lesson.
  completing,

  /// Lesson completed successfully.
  completed,

  /// An error occurred.
  error,
}
