import 'package:codedly/features/quizzes/domain/entities/module.dart' as entity;

class ModuleModel extends entity.Module {
  const ModuleModel({
    required super.id,
    required super.titleEn,
    required super.titleId,
    super.descriptionEn,
    super.descriptionId,
    required super.orderIndex,
    required super.difficultyLevel,
    super.estimatedDurationMinutes,
    required super.requiredLevel,
    required super.isPublished,
    super.totalQuizzes,
    super.quizzesCompleted,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      titleEn: json['title_en'] as String,
      titleId: json['title_id'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionId: json['description_id'] as String?,
      orderIndex: json['order_index'] as int,
      difficultyLevel: json['difficulty_level'] as String,
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int?,
      requiredLevel: json['required_level'] as int,
      isPublished: json['is_published'] as bool,
      totalQuizzes: json['total_quiz'] as int? ?? 0,
      quizzesCompleted: json['quiz_completed'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_en': titleEn,
      'title_id': titleId,
      'description_en': descriptionEn,
      'description_id': descriptionId,
      'order_index': orderIndex,
      'difficulty_level': difficultyLevel,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'required_level': requiredLevel,
      'is_published': isPublished,
      'total_quiz': totalQuizzes,
      'quiz_completed': quizzesCompleted,
    };
  }
}