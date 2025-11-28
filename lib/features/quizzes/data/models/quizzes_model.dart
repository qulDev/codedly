import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';

/// Quizzes data model.
/// Extends [Quizzes] entity with JSON serialization capabilities.
class QuizzesModel extends Quizzes {
  const QuizzesModel({
    required super.id,
    required super.moduleId,
    required super.titleEn,
    required super.titleId,
    required super.contentEn,
    required super.contentId,
    required super.optionsEn,
    required super.optionsId,
    required super.correctAnswerIndex,
    super.codeTemplate,
    super.expectedOutput,
    required super.validationType,
    super.validationPattern,
    required super.orderIndex,
    required super.xpReward,
    super.estimatedDurationMinutes,
    required super.isPublished,
    super.isCompleted,
    super.hint,
  });

  /// Creates a [QuizzesModel] from JSON.
  factory QuizzesModel.fromJson(Map<String, dynamic> json) {
    return QuizzesModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      titleEn: json['title_en'] as String,
      titleId: json['title_id'] as String,
      contentEn: json['content_en'] as String,
      contentId: json['content_id'] as String,
      optionsEn: List<String>.from(json['options_en'] ?? []),
      optionsId: List<String>.from(json['options_id'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] as int,
      codeTemplate: json['code_template'] as String?,
      expectedOutput: json['expected_output'] as String?,
      validationType: json['validation_type'] as String,
      validationPattern: json['validation_pattern'] as String?,
      orderIndex: json['order_index'] as int,
      xpReward: json['xp_reward'] as int,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      isPublished: json['is_published'] as bool,
      isCompleted: json['is_completed'] as bool? ?? false,
      hint: json['hint'] as String?,
    );
  }

  /// Converts this [QuizzesModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title_en': titleEn,
      'title_id': titleId,
      'content_en': contentEn,
      'content_id': contentId,
      'options_en': optionsEn,
      'options_id': optionsId,
      'correct_answer_index': correctAnswerIndex,
      'code_template': codeTemplate,
      'expected_output': expectedOutput,
      'validation_type': validationType,
      'validation_pattern': validationPattern,
      'order_index': orderIndex,
      'xp_reward': xpReward,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_published': isPublished,
      'is_completed': isCompleted,
      'hint': hint,
    };
  }
}
