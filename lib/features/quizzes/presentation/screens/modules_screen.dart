import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/l10n/generated/app_localizations.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_state.dart';
import 'package:codedly/features/quizzes/presentation/screens/quizzes_list_screen.dart';

class QuizzesModuleScreen extends ConsumerWidget {
  const QuizzesModuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final quizzesState = ref.watch(quizzesProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.quizzes),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(quizzesProvider.notifier).refreshModules();
        },
        color: AppColors.primary,
        child: quizzesState.status == QuizzesStatus.loading &&
                quizzesState.modules.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : quizzesState.modules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.quiz,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noQuizzesAvailable,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: quizzesState.modules.length,
                    itemBuilder: (context, index) {
                      final module = quizzesState.modules[index];
                       debugPrint('MODULE DATA => $module');
                      debugPrint('TITLE => ${module.getTitle(languageCode)}');
                      debugPrint('QUIZZES COMPLETED => ${module.quizzesCompleted}');
                      debugPrint('TOTAL QUIZZES => ${module.totalQuizzes}');
                      debugPrint('DIFFICULTY => ${module.difficultyLevel}');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _QuizModuleCard(
                          title: module.getTitle(languageCode),
                          description:
                              module.getDescription(languageCode) ?? '',
                          difficulty: module.difficultyLevel,
                          quizzesCompleted: module.quizzesCompleted,
                          totalQuizzes: module.totalQuizzes,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizListScreen(
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

class _QuizModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty;
  final int quizzesCompleted;
  final int totalQuizzes;
  final VoidCallback onTap; 

  const _QuizModuleCard({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.quizzesCompleted,
    required this.totalQuizzes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalQuizzes > 0 ? quizzesCompleted / totalQuizzes : 0.0;

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
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1 ? Colors.green : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$quizzesCompleted/$totalQuizzes',
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
