import 'package:codedly/features/lessons/domain/entities/lesson_hint.dart';

/// Lesson hint data model.
///
/// Extends [LessonHint] entity with JSON serialization capabilities.
class LessonHintModel extends LessonHint {
  const LessonHintModel({
    required super.id,
    required super.lessonId,
    required super.hintTextEn,
    required super.hintTextId,
    required super.orderIndex,
  });

  /// Creates a [LessonHintModel] from JSON.
  factory LessonHintModel.fromJson(Map<String, dynamic> json) {
    return LessonHintModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String,
      hintTextEn: json['hint_text_en'] as String,
      hintTextId: json['hint_text_id'] as String,
      orderIndex: json['order_index'] as int,
    );
  }

  /// Converts this [LessonHintModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'hint_text_en': hintTextEn,
      'hint_text_id': hintTextId,
      'order_index': orderIndex,
    };
  }
}
