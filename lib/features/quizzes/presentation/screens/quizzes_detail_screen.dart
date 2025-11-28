import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_provider.dart';

class QuizDetailScreen extends ConsumerStatefulWidget {
  final int quizIndex;

  const QuizDetailScreen({super.key, required this.quizIndex});

  @override
  ConsumerState<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends ConsumerState<QuizDetailScreen> {
  int? _selectedOption;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(quizzesProvider.notifier).setCurrentQuiz(widget.quizIndex);
    });
  }

  void _submitAnswer() async {
    final quizzesState = ref.read(quizzesProvider);
    final quiz = quizzesState.currentQuiz;
    if (quiz == null || _selectedOption == null) return;

    final isCorrect = _selectedOption == quiz.correctAnswerIndex;

    if (isCorrect) {
      await ref.read(quizzesProvider.notifier).completeCurrentQuiz();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Correct! +${quiz.xpReward} XP'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Incorrect answer. Try again!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final quizzesState = ref.watch(quizzesProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';
    final quiz = quizzesState.currentQuiz;

    if (quiz == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    final options = quiz.getOptions(languageCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(quiz.getTitle(languageCode)),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.getContent(languageCode),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 20, color: AppColors.xpGold),
                      const SizedBox(width: 8),
                      Text(
                        '${quiz.xpReward} XP Reward',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xpGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = _selectedOption == index;
                return Card(
                  color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                  child: ListTile(
                    title: Text(option, style: const TextStyle(color: AppColors.textPrimary)),
                    leading: Radio<int>(
                      value: index,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedOption = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: ElevatedButton.icon(
              onPressed: _selectedOption == null ? null : _submitAnswer,
              icon: const Icon(Icons.check),
              label: const Text('Submit Answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
