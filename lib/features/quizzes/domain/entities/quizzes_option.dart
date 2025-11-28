import 'package:equatable/equatable.dart';

/// Quiz option entity.
/// 
/// Represents selectable answer options for a quiz question.
class QuizOption extends Equatable {
  /// List of options in English.
  final List<String> optionsEn;

  /// List of options in Indonesian.
  final List<String> optionsId;

  /// Correct answer index in the options list.
  final int correctAnswerIndex;

  const QuizOption({
    required this.optionsEn,
    required this.optionsId,
    required this.correctAnswerIndex,
  });

  /// Returns localized list of options based on language preference.
  List<String> getOptions(String languageCode) {
    return languageCode == 'id' ? optionsId : optionsEn;
  }

  /// Returns the correct answer text based on language preference.
  String getCorrectAnswer(String languageCode) {
    final list = getOptions(languageCode);
    return list[correctAnswerIndex];
  }

  @override
  List<Object?> get props => [optionsEn, optionsId, correctAnswerIndex];
}
