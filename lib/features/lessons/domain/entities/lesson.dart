import 'package:equatable/equatable.dart';

/// Lesson entity.
///
/// Represents an individual learning lesson with code challenges.
class Lesson extends Equatable {
  /// The lesson's unique identifier.
  final String id;

  /// Module ID this lesson belongs to.
  final String moduleId;

  /// Lesson title in English.
  final String titleEn;

  /// Lesson title in Indonesian.
  final String titleId;

  /// Lesson content/instructions in English.
  final String contentEn;

  /// Lesson content/instructions in Indonesian.
  final String contentId;

  /// Initial code template for the lesson.
  final String? codeTemplate;

  /// Expected output for validation.
  final String? expectedOutput;

  /// Validation type: output, pattern, custom.
  final String validationType;

  /// Validation pattern (for pattern validation).
  final String? validationPattern;

  /// Order index within the module.
  final int orderIndex;

  /// XP reward for completing the lesson.
  final int xpReward;

  /// Estimated duration in minutes.
  final int? estimatedDurationMinutes;

  /// Whether the lesson is published.
  final bool isPublished;

  /// Whether the user has completed this lesson.
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.titleEn,
    required this.titleId,
    required this.contentEn,
    required this.contentId,
    this.codeTemplate,
    this.expectedOutput,
    required this.validationType,
    this.validationPattern,
    required this.orderIndex,
    required this.xpReward,
    this.estimatedDurationMinutes,
    required this.isPublished,
    this.isCompleted = false,
  });

  /// Gets the localized title based on language preference.
  String getTitle(String languageCode) {
    return languageCode == 'id' ? titleId : titleEn;
  }

  /// Gets the localized content based on language preference.
  String getContent(String languageCode) {
    return languageCode == 'id' ? contentId : contentEn;
  }

  /// Creates a copy with the given fields replaced.
  Lesson copyWith({
    String? id,
    String? moduleId,
    String? titleEn,
    String? titleId,
    String? contentEn,
    String? contentId,
    String? codeTemplate,
    String? expectedOutput,
    String? validationType,
    String? validationPattern,
    int? orderIndex,
    int? xpReward,
    int? estimatedDurationMinutes,
    bool? isPublished,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      contentEn: contentEn ?? this.contentEn,
      contentId: contentId ?? this.contentId,
      codeTemplate: codeTemplate ?? this.codeTemplate,
      expectedOutput: expectedOutput ?? this.expectedOutput,
      validationType: validationType ?? this.validationType,
      validationPattern: validationPattern ?? this.validationPattern,
      orderIndex: orderIndex ?? this.orderIndex,
      xpReward: xpReward ?? this.xpReward,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isPublished: isPublished ?? this.isPublished,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    moduleId,
    titleEn,
    titleId,
    contentEn,
    contentId,
    codeTemplate,
    expectedOutput,
    validationType,
    validationPattern,
    orderIndex,
    xpReward,
    estimatedDurationMinutes,
    isPublished,
    isCompleted,
  ];
}
