import 'package:codedly/features/quizzes/presentation/screens/quizzes_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_state.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const QuizListScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    // Load quizzes when screen opens
    Future.microtask(() {
      ref.read(quizzesProvider.notifier).loadQuizzes(widget.moduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final quizzesState = ref.watch(quizzesProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.moduleTitle),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: quizzesState.status == QuizzesStatus.loading &&
              quizzesState.quizzes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : quizzesState.quizzes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No quizzes available yet',
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
                  itemCount: quizzesState.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzesState.quizzes[
                        quizzesState.quizzes.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuizCard(
                        number: index + 1,
                        title: quiz.getTitle(languageCode),
                        xpReward: quiz.xpReward,
                        isCompleted: quiz.isCompleted,
                        onTap: () {
                          ref
                              .read(quizzesProvider.notifier)
                              .setCurrentQuiz(
                                  quizzesState.quizzes.length - 1 - index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizDetailScreen(
                                quizIndex:
                                    quizzesState.quizzes.length - 1 - index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final int number;
  final String title;
  final int xpReward;
  final bool isCompleted;
  final VoidCallback onTap;

  const _QuizCard({
    required this.number,
    required this.title,
    required this.xpReward,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.surfaceVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                        '$number',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.stars,
                          size: 16, color: AppColors.xpGold),
                      const SizedBox(width: 4),
                      Text(
                        '$xpReward XP',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.xpGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
