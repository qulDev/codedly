import 'package:equatable/equatable.dart';

/// Lesson hint entity.
///
/// Represents a hint that helps users complete a lesson.
class LessonHint extends Equatable {
  /// The hint's unique identifier.
  final String id;

  /// Lesson ID this hint belongs to.
  final String lessonId;

  /// Hint text in English.
  final String hintTextEn;

  /// Hint text in Indonesian.
  final String hintTextId;

  /// Order index for display.
  final int orderIndex;

  const LessonHint({
    required this.id,
    required this.lessonId,
    required this.hintTextEn,
    required this.hintTextId,
    required this.orderIndex,
  });

  /// Gets the localized hint text based on language preference.
  String getHintText(String languageCode) {
    return languageCode == 'id' ? hintTextId : hintTextEn;
  }

  @override
  List<Object?> get props => [id, lessonId, hintTextEn, hintTextId, orderIndex];
}
