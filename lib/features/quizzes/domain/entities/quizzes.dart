import 'package:equatable/equatable.dart';

/// Quizzes entity
class Quizzes extends Equatable {
  final String id;
  final String moduleId;
  final String titleEn;
  final String titleId;
  final String contentEn;
  final String contentId;

  /// List of options per language
  final List<String> optionsEn;
  final List<String> optionsId;

  /// Index of the correct answer in options list
  final int correctAnswerIndex;

  final String? codeTemplate;
  final String? expectedOutput;
  final String validationType;
  final String? validationPattern;

  final int orderIndex;
  final int xpReward;
  final int? estimatedDurationMinutes;

  final bool isPublished;
  final bool isCompleted;

  /// Optional hint or additional info
  final String? hint;

  const Quizzes({
    required this.id,
    required this.moduleId,
    required this.titleEn,
    required this.titleId,
    required this.contentEn,
    required this.contentId,
    required this.optionsEn,
    required this.optionsId,
    required this.correctAnswerIndex,
    this.codeTemplate,
    this.expectedOutput,
    required this.validationType,
    this.validationPattern,
    required this.orderIndex,
    required this.xpReward,
    this.estimatedDurationMinutes,
    required this.isPublished,
    this.isCompleted = false,
    this.hint,
  });

  String getTitle(String languageCode) =>
      languageCode == 'id' ? titleId : titleEn;

  String getContent(String languageCode) =>
      languageCode == 'id' ? contentId : contentEn;

  List<String> getOptions(String languageCode) =>
      languageCode == 'id' ? optionsId : optionsEn;

  Quizzes copyWith({
    String? id,
    String? moduleId,
    String? titleEn,
    String? titleId,
    String? contentEn,
    String? contentId,
    List<String>? optionsEn,
    List<String>? optionsId,
    int? correctAnswerIndex,
    String? codeTemplate,
    String? expectedOutput,
    String? validationType,
    String? validationPattern,
    int? orderIndex,
    int? xpReward,
    int? estimatedDurationMinutes,
    bool? isPublished,
    bool? isCompleted,
    String? hint,
  }) {
    return Quizzes(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      contentEn: contentEn ?? this.contentEn,
      contentId: contentId ?? this.contentId,
      optionsEn: optionsEn ?? this.optionsEn,
      optionsId: optionsId ?? this.optionsId,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
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
      hint: hint ?? this.hint,
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
        optionsEn,
        optionsId,
        correctAnswerIndex,
        codeTemplate,
        expectedOutput,
        validationType,
        validationPattern,
        orderIndex,
        xpReward,
        estimatedDurationMinutes,
        isPublished,
        isCompleted,
        hint,
      ];
}
