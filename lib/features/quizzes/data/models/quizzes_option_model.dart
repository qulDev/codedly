import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';

class QuizOptionModel extends QuizOption {
  QuizOptionModel({
    required List<String> optionsEn,
    required List<String> optionsId,
    required int correctAnswerIndex,
  }) : super(
          optionsEn: optionsEn,
          optionsId: optionsId,
          correctAnswerIndex: correctAnswerIndex,
        );

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      optionsEn: List<String>.from(json['options_en'] ?? []),
      optionsId: List<String>.from(json['options_id'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'options_en': optionsEn,
      'options_id': optionsId,
      'correct_answer_index': correctAnswerIndex,
    };
  }

  QuizOption toEntity() {
    return QuizOption(
      optionsEn: optionsEn,
      optionsId: optionsId,
      correctAnswerIndex: correctAnswerIndex,
    );
  }
}
