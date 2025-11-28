import 'package:equatable/equatable.dart';
import 'package:codedly/features/quizzes/domain/entities/module.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';

/// State for modules and quizzes.
class QuizzesState extends Equatable {
  final QuizzesStatus status;
  final List<Module> modules;
  final List<Quizzes> quizzes;
  final Quizzes? currentQuiz;
  final String? errorMessage;

  const QuizzesState({
    this.status = QuizzesStatus.initial,
    this.modules = const [],
    this.quizzes = const [],
    this.currentQuiz,
    this.errorMessage,
  });

  QuizzesState copyWith({
    QuizzesStatus? status,
    List<Module>? modules,
    List<Quizzes>? quizzes,
    Quizzes? currentQuiz,
    String? errorMessage,
    bool clearCurrentQuiz = false,
  }) {
    return QuizzesState(
      status: status ?? this.status,
      modules: modules ?? this.modules,
      quizzes: quizzes ?? this.quizzes,
      currentQuiz: clearCurrentQuiz
          ? null
          : (currentQuiz ?? this.currentQuiz),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        modules,
        quizzes,
        currentQuiz,
        errorMessage,
      ];
}

/// Status values for [QuizzesState].
enum QuizzesStatus {
  /// Initial state, no data loaded yet.
  initial,

  /// Loading modules or quizzes.
  loading,

  /// Data loaded successfully.
  loaded,

  /// Completing a quiz.
  completing,

  /// Quiz completed successfully.
  completed,

  /// An error occurred.
  error,
}
