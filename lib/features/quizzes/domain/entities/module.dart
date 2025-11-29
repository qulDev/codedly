import 'package:equatable/equatable.dart';

/// Learning module entity.
/// Represents a collection of quizzes on a specific topic.
class Module extends Equatable {
  /// The module's unique identifier.
  final String id;

  /// Module title in English.
  final String titleEn;

  /// Module title in Indonesian.
  final String titleId;

  /// Module description in English.
  final String? descriptionEn;

  /// Module description in Indonesian.
  final String? descriptionId;

  /// Order index for display.
  final int orderIndex;

  /// Difficulty level: beginner, intermediate, advanced.
  final String difficultyLevel;

  /// Estimated duration in minutes.
  final int? estimatedDurationMinutes;

  /// Required user level to access.
  final int requiredLevel;

  /// Whether the module is published.
  final bool isPublished;

  /// Number of quizzes in this module.
  final int totalQuizzes;

  /// Number of quizzes completed by the user.
  final int quizzesCompleted;

  const Module({
    required this.id,
    required this.titleEn,
    required this.titleId,
    this.descriptionEn,
    this.descriptionId,
    required this.orderIndex,
    required this.difficultyLevel,
    this.estimatedDurationMinutes,
    required this.requiredLevel,
    required this.isPublished,
    this.totalQuizzes = 0,
    this.quizzesCompleted = 0,
  });

  /// Gets the localized title based on language preference.
  String getTitle(String languageCode) {
    return languageCode == 'id' ? titleId : titleEn;
  }

  /// Gets the localized description based on language preference.
  String? getDescription(String languageCode) {
    return languageCode == 'id' ? descriptionId : descriptionEn;
  }

  /// Calculates quiz completion percentage.
  double get completionPercentage {
    if (totalQuizzes == 0) return 0.0;
    return quizzesCompleted / totalQuizzes;
  }

  /// Creates a copy with the given fields replaced.
  Module copyWith({
    String? id,
    String? titleEn,
    String? titleId,
    String? descriptionEn,
    String? descriptionId,
    int? orderIndex,
    String? difficultyLevel,
    int? estimatedDurationMinutes,
    int? requiredLevel,
    bool? isPublished,
    int? totalQuizzes,
    int? quizzesCompleted,
  }) {
    return Module(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionId: descriptionId ?? this.descriptionId,
      orderIndex: orderIndex ?? this.orderIndex,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      isPublished: isPublished ?? this.isPublished,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        titleEn,
        titleId,
        descriptionEn,
        descriptionId,
        orderIndex,
        difficultyLevel,
        estimatedDurationMinutes,
        requiredLevel,
        isPublished,
        totalQuizzes,
        quizzesCompleted,
      ];
}
