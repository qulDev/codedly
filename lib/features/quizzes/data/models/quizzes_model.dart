import 'package:codedly/features/quizzes/domain/entities/quizzes.dart';

/// Quizzes data model.
/// Extends [Quizzes] entity with JSON serialization capabilities.
class QuizzesModel extends Quizzes {
  const QuizzesModel({
    required super.id,
    required super.moduleId,
    required super.titleEn,
    required super.titleId,
    super.descriptionEn,
    super.descriptionId,
    required super.orderIndex,
    required super.passingScorePercentage,
    required super.xpPerCorrectAnswer,
    required super.bonusXpForPerfect,
    required super.isPublished,
    super.isCompleted,
  });

  /// Creates a [QuizzesModel] from JSON.
  factory QuizzesModel.fromJson(Map<String, dynamic> json) {
    return QuizzesModel(
      id: json['id'] as String,
      moduleId: json['module_id'] as String,
      titleEn: json['title_en'] as String,
      titleId: json['title_id'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionId: json['description_id'] as String?,
      orderIndex: json['order_index'] as int,
      passingScorePercentage: json['passing_score_percentage'] as int? ?? 70,
      xpPerCorrectAnswer: json['xp_per_correct_answer'] as int? ?? 5,
      bonusXpForPerfect: json['bonus_xp_for_perfect'] as int? ?? 10,
      isPublished: json['is_published'] as bool,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  /// Converts this [QuizzesModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module_id': moduleId,
      'title_en': titleEn,
      'title_id': titleId,
      'description_en': descriptionEn,
      'description_id': descriptionId,
      'order_index': orderIndex,
      'passing_score_percentage': passingScorePercentage,
      'xp_per_correct_answer': xpPerCorrectAnswer,
      'bonus_xp_for_perfect': bonusXpForPerfect,
      'is_published': isPublished,
      'is_completed': isCompleted,
    };
  }
}
