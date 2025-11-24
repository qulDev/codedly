import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/l10n/generated/app_localizations.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_provider.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_state.dart';
import 'package:codedly/features/lessons/presentation/screens/lesson_list_screen.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final lessonsState = ref.watch(lessonsProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.lessons),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(lessonsProvider.notifier).refreshModules();
        },
        color: AppColors.primary,
        child:
            lessonsState.status == LessonsStatus.loading &&
                lessonsState.modules.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : lessonsState.modules.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No modules available yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessonsState.modules.length,
                itemBuilder: (context, index) {
                  final module = lessonsState.modules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ModuleCard(
                      title: module.getTitle(languageCode),
                      description: module.getDescription(languageCode) ?? '',
                      difficulty: module.difficultyLevel,
                      lessonsCompleted: module.lessonsCompleted,
                      totalLessons: module.totalLessons,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonListScreen(
                              moduleId: module.id,
                              moduleTitle: module.getTitle(languageCode),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty;
  final int lessonsCompleted;
  final int totalLessons;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons > 0 ? lessonsCompleted / totalLessons : 0.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    difficulty[0].toUpperCase() + difficulty.substring(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: AppColors.primary),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$lessonsCompleted/$totalLessons',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
