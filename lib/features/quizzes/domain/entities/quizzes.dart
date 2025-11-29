import 'package:equatable/equatable.dart';

/// Quiz entity - represents a quiz container within a module
class Quizzes extends Equatable {
  final String id;
  final String moduleId;
  final String titleEn;
  final String titleId;
  final String? descriptionEn;
  final String? descriptionId;
  final int orderIndex;
  final int passingScorePercentage;
  final int xpPerCorrectAnswer;
  final int bonusXpForPerfect;
  final bool isPublished;
  final bool isCompleted;

  const Quizzes({
    required this.id,
    required this.moduleId,
    required this.titleEn,
    required this.titleId,
    this.descriptionEn,
    this.descriptionId,
    required this.orderIndex,
    required this.passingScorePercentage,
    required this.xpPerCorrectAnswer,
    required this.bonusXpForPerfect,
    required this.isPublished,
    this.isCompleted = false,
  });

  String getTitle(String languageCode) =>
      languageCode == 'id' ? titleId : titleEn;

  String? getDescription(String languageCode) =>
      languageCode == 'id' ? descriptionId : descriptionEn;

  /// Calculate total XP reward based on number of questions
  int get xpReward => xpPerCorrectAnswer * 5 + bonusXpForPerfect; // Estimate

  Quizzes copyWith({
    String? id,
    String? moduleId,
    String? titleEn,
    String? titleId,
    String? descriptionEn,
    String? descriptionId,
    int? orderIndex,
    int? passingScorePercentage,
    int? xpPerCorrectAnswer,
    int? bonusXpForPerfect,
    bool? isPublished,
    bool? isCompleted,
  }) {
    return Quizzes(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      titleEn: titleEn ?? this.titleEn,
      titleId: titleId ?? this.titleId,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionId: descriptionId ?? this.descriptionId,
      orderIndex: orderIndex ?? this.orderIndex,
      passingScorePercentage:
          passingScorePercentage ?? this.passingScorePercentage,
      xpPerCorrectAnswer: xpPerCorrectAnswer ?? this.xpPerCorrectAnswer,
      bonusXpForPerfect: bonusXpForPerfect ?? this.bonusXpForPerfect,
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
    descriptionEn,
    descriptionId,
    orderIndex,
    passingScorePercentage,
    xpPerCorrectAnswer,
    bonusXpForPerfect,
    isPublished,
    isCompleted,
  ];
}
