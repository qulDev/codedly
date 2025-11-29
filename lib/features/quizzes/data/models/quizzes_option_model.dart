import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';

class QuizOptionModel extends QuizQuestion {
  const QuizOptionModel({
    required super.id,
    required super.quizId,
    required super.questionTextEn,
    required super.questionTextId,
    required super.optionsEn,
    required super.optionsId,
    required super.correctAnswerIndex,
    super.explanationEn,
    super.explanationId,
    required super.orderIndex,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    List<String> parseOptions(dynamic value) {
      if (value == null) return [];
      if (value is List) return List<String>.from(value);
      if (value is String) {
        try {
          final decoded = value.startsWith('[')
              ? (value
                    .substring(1, value.length - 1)
                    .split(',')
                    .map((e) => e.trim().replaceAll('"', ''))
                    .toList())
              : [value];
          return decoded;
        } catch (_) {
          return [value];
        }
      }
      return [];
    }

    return QuizOptionModel(
      id: json['id'] as String,
      quizId: json['quiz_id'] as String,
      questionTextEn: json['question_text_en'] as String,
      questionTextId: json['question_text_id'] as String,
      optionsEn: parseOptions(json['options_en']),
      optionsId: parseOptions(json['options_id']),
      correctAnswerIndex: json['correct_answer_index'] as int? ?? 0,
      explanationEn: json['explanation_en'] as String?,
      explanationId: json['explanation_id'] as String?,
      orderIndex: json['order_index'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'question_text_en': questionTextEn,
      'question_text_id': questionTextId,
      'options_en': optionsEn,
      'options_id': optionsId,
      'correct_answer_index': correctAnswerIndex,
      'explanation_en': explanationEn,
      'explanation_id': explanationId,
      'order_index': orderIndex,
    };
  }

  QuizQuestion toEntity() {
    return QuizQuestion(
      id: id,
      quizId: quizId,
      questionTextEn: questionTextEn,
      questionTextId: questionTextId,
      optionsEn: optionsEn,
      optionsId: optionsId,
      correctAnswerIndex: correctAnswerIndex,
      explanationEn: explanationEn,
      explanationId: explanationId,
      orderIndex: orderIndex,
    );
  }
}
