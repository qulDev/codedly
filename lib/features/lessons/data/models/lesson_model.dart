import 'package:codedly/features/lessons/domain/entities/lesson.dart';

/// Lesson data model.
///
/// Extends [Lesson] entity with JSON serialization capabilities.
class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.moduleId,
    required super.titleEn,
    required super.titleId,
    required super.contentEn,
    required super.contentId,
    super.codeTemplate,
    super.expectedOutput,
    required super.validationType,
    super.validationPattern,
    required super.orderIndex,
    required super.xpReward,
    super.estimatedDurationMinutes,
    required super.isPublished,
    super.isCompleted,
  });

  /// Creates a [LessonModel] from JSON.
  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      titleEn: json['title_en'] as String,
      titleId: json['title_id'] as String,
      contentEn: json['content_en'] as String,
      contentId: json['content_id'] as String,
      codeTemplate: json['code_template'] as String?,
      expectedOutput: json['expected_output'] as String?,
      validationType: json['validation_type'] as String,
      validationPattern: json['validation_pattern'] as String?,
      orderIndex: json['order_index'] as int,
      xpReward: json['xp_reward'] as int,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      isPublished: json['is_published'] as bool,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  /// Converts this [LessonModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title_en': titleEn,
      'title_id': titleId,
      'content_en': contentEn,
      'content_id': contentId,
      'code_template': codeTemplate,
      'expected_output': expectedOutput,
      'validation_type': validationType,
      'validation_pattern': validationPattern,
      'order_index': orderIndex,
      'xp_reward': xpReward,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_published': isPublished,
      'is_completed': isCompleted,
    };
  }
}
