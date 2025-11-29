import 'package:equatable/equatable.dart';

/// Quiz Question entity.
///
/// Represents an individual question within a quiz.
class QuizQuestion extends Equatable {
  final String id;
  final String quizId;
  final String questionTextEn;
  final String questionTextId;
  final List<String> optionsEn;
  final List<String> optionsId;
  final int correctAnswerIndex;
  final String? explanationEn;
  final String? explanationId;
  final int orderIndex;

  const QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionTextEn,
    required this.questionTextId,
    required this.optionsEn,
    required this.optionsId,
    required this.correctAnswerIndex,
    this.explanationEn,
    this.explanationId,
    required this.orderIndex,
  });

  String getQuestionText(String languageCode) {
    return languageCode == 'id' ? questionTextId : questionTextEn;
  }

  List<String> getOptions(String languageCode) {
    return languageCode == 'id' ? optionsId : optionsEn;
  }

  String? getExplanation(String languageCode) {
    return languageCode == 'id' ? explanationId : explanationEn;
  }

  String getCorrectAnswer(String languageCode) {
    final list = getOptions(languageCode);
    return list[correctAnswerIndex];
  }

  @override
  List<Object?> get props => [
    id,
    quizId,
    questionTextEn,
    questionTextId,
    optionsEn,
    optionsId,
    correctAnswerIndex,
    explanationEn,
    explanationId,
    orderIndex,
  ];
}

typedef QuizOption = QuizQuestion;
