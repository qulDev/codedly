import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_provider.dart';
import 'package:codedly/features/quizzes/presentation/providers/quizzes_state.dart';
import 'package:codedly/features/quizzes/domain/entities/quizzes_option.dart';

class QuizDetailScreen extends ConsumerStatefulWidget {
  final int quizIndex;

  const QuizDetailScreen({super.key, required this.quizIndex});

  @override
  ConsumerState<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends ConsumerState<QuizDetailScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _answered = false;
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(quizzesProvider.notifier).setCurrentQuiz(widget.quizIndex);
      _loadQuestions();
    });
  }

  Future<void> _loadQuestions() async {
    final quizzesState = ref.read(quizzesProvider);
    final quiz = quizzesState.currentQuiz;
    if (quiz == null) return;

    await ref.read(quizzesProvider.notifier).loadQuestions(quiz.id);
  }

  void _submitAnswer() {
    if (_selectedOption == null || _questions.isEmpty) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _selectedOption == currentQuestion.correctAnswerIndex;

    if (isCorrect) {
      _correctAnswers++;
    }

    setState(() {
      _answered = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
          _answered = false;
        });
      } else {
        // Quiz completed
        _completeQuiz();
      }
    });
  }

  Future<void> _completeQuiz() async {
    final quizzesState = ref.read(quizzesProvider);
    final quiz = quizzesState.currentQuiz;
    if (quiz == null) return;

    final totalQuestions = _questions.length;
    final scorePercentage = totalQuestions > 0
        ? (_correctAnswers / totalQuestions * 100).round()
        : 0;
    final passed = scorePercentage >= quiz.passingScorePercentage;

    if (passed) {
      await ref.read(quizzesProvider.notifier).completeCurrentQuiz();
    }

    setState(() {
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final quizzesState = ref.watch(quizzesProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';
    final quiz = quizzesState.currentQuiz;
    _questions = quizzesState.questions;

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

    if (quizzesState.status == QuizzesStatus.loading && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(quiz.getTitle(languageCode)),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(quiz.getTitle(languageCode)),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 64, color: AppColors.textSecondary),
              SizedBox(height: 16),
              Text(
                'No questions available',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_showResult) {
      return _buildResultScreen(quiz, languageCode);
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final options = currentQuestion.getOptions(languageCode);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(quiz.getTitle(languageCode)),
        backgroundColor: AppColors.surface,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentQuestion.getQuestionText(languageCode),
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Options
                  ...List.generate(options.length, (index) {
                    final isSelected = _selectedOption == index;
                    final isCorrect =
                        index == currentQuestion.correctAnswerIndex;

                    Color? cardColor = AppColors.surface;
                    Color? borderColor = AppColors.surfaceVariant;

                    if (_answered) {
                      if (isCorrect) {
                        cardColor = Colors.green.withOpacity(0.2);
                        borderColor = Colors.green;
                      } else if (isSelected && !isCorrect) {
                        cardColor = Colors.red.withOpacity(0.2);
                        borderColor = Colors.red;
                      }
                    } else if (isSelected) {
                      cardColor = AppColors.primary.withOpacity(0.2);
                      borderColor = AppColors.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: _answered
                            ? null
                            : () {
                                setState(() {
                                  _selectedOption = index;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                      65 + index,
                                    ), // A, B, C, D
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_answered && isCorrect)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              if (_answered && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  // Show explanation after answering
                  if (_answered &&
                      currentQuestion.getExplanation(languageCode) != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentQuestion.getExplanation(languageCode)!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Submit button
          if (!_answered)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOption == null ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(quiz, String languageCode) {
    final totalQuestions = _questions.length;
    final scorePercentage = totalQuestions > 0
        ? (_correctAnswers / totalQuestions * 100).round()
        : 0;
    final passed = scorePercentage >= quiz.passingScorePercentage;
    final xpEarned = passed ? quiz.xpReward : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quiz Result'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.celebration : Icons.sentiment_dissatisfied,
                size: 80,
                color: passed ? AppColors.primary : Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Congratulations!' : 'Keep Learning!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You scored $scorePercentage%',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_correctAnswers out of $totalQuestions correct',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              if (passed) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.xpGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: AppColors.xpGold),
                      const SizedBox(width: 8),
                      Text(
                        '+$xpEarned XP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.xpGold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (!passed) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentQuestionIndex = 0;
                      _selectedOption = null;
                      _correctAnswers = 0;
                      _showResult = false;
                      _answered = false;
                    });
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
