import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_provider.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_state.dart';

String _parseText(String content) {
  content = content.replaceAll(r'\n', '\n');
  content = content.replaceAllMapped(
    RegExp(r'`(.*?)`'),
    (match) {
      return '<code>${match.group(1)}</code>';
    },
  );

  return content;
}
// // # Variabel\n\nVariabel menyimpan nilai. Buat variabel bernama `age` dan atur ke 15.\n\nKemudian cetak: "I am 15 years old"
class LessonDetailScreen extends ConsumerStatefulWidget {
  final int lessonIndex;

  const LessonDetailScreen({super.key, required this.lessonIndex});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late TextEditingController _codeController;
  late final String lessonContent;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    // Set initial code template
    Future.microtask(() {
      final lesson = ref.read(lessonsProvider).currentLesson;
      if (lesson?.codeTemplate != null) {
        _codeController.text = lesson!.codeTemplate!;
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final lessonsState = ref.watch(lessonsProvider);
    final languageCode = authState.user?.languagePreference ?? 'en';
    final lesson = lessonsState.currentLesson;
    final lessonContent = _parseText(lesson?.getContent(languageCode) ?? '');

    if (lesson == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Lesson'),
          backgroundColor: AppColors.surface,
        ),
        body: const Center(child: Text('Lesson not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lesson.getTitle(languageCode)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (lesson.isCompleted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Completed'),
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      children: _buildText(lessonContent).children,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.stars, size: 20, color: AppColors.xpGold),
                      const SizedBox(width: 8),
                      Text(
                        '${lesson.xpReward} XP Reward',
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

          // Code Editor
          Expanded(
            flex: 3,
            child: Container(
              color: AppColors.surface,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: AppColors.surfaceVariant,
                    child: const Row(
                      children: [
                        Icon(Icons.code, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Python Editor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _codeController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write your Python code here...',
                        hintStyle: TextStyle(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Show hints
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hints feature coming soon! 💡'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Hint'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: lessonsState.status == LessonsStatus.completing
                        ? null
                        : () async {
                            // TODO: Validate code first
                            // For now, just complete the lesson
                            await ref
                                .read(lessonsProvider.notifier)
                                .completeCurrentLesson();

                            if (lessonsState.status ==
                                    LessonsStatus.completed &&
                                mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '🎉 Lesson completed! +${lesson.xpReward} XP',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                    icon: lessonsState.status == LessonsStatus.completing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(lesson.isCompleted ? 'Completed' : 'Run Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lesson.isCompleted
                          ? AppColors.surfaceVariant
                          : AppColors.primary,
                      foregroundColor: lesson.isCompleted
                          ? AppColors.textSecondary
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
 TextSpan _buildText(String content) {
    final spans = <TextSpan>[];
    final codeRegex = RegExp(r'<code>(.*?)</code>');
    int lastMatchEnd = 0;
    final matches = codeRegex.allMatches(content);
    for (final match in matches) {
      // Add normal text before the code
      if (match.start > lastMatchEnd) {
        final normalText = content.substring(lastMatchEnd, match.start);
        spans.addAll(_highlightQuotes(normalText));
      }
      // Add code snippet
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w100
        ),
      ));
      lastMatchEnd = match.end;
    }
    // Add any remaining normal text after the last code
    if (lastMatchEnd < content.length) {
      final normalText = content.substring(lastMatchEnd);
      spans.addAll(_highlightQuotes(normalText));
    }
    return TextSpan(children: spans);
  }

  List<TextSpan> _highlightQuotes(String text) {
    final spans = <TextSpan>[];
    final quoteRegex = RegExp(r'"([^"]*)"');
    int lastEnd = 0;
    for (final match in quoteRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ));
      }
      spans.add(TextSpan(
        text: '"${match.group(1)}"',
        style: const TextStyle(
          fontSize: 16,
          color: Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ));
    }
    return spans;
  }
}