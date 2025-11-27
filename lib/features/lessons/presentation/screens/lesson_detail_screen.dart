import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_python_bridge/flutter_python_bridge.dart' show PythonBridge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'dart:convert';

import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/core/di/injection.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/lessons/domain/entities/lesson_hint.dart';
import 'package:codedly/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_provider.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final int lessonIndex;

  const LessonDetailScreen({super.key, required this.lessonIndex});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  late TextEditingController _codeController;
  PythonBridge? pythonBridge;
  late final String lessonContent;
  String _output = '';
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
    
    if (!kIsWeb) {
      pythonBridge = PythonBridge();
    }
    
    Future.microtask(() {
      final lesson = ref.read(lessonsProvider).currentLesson;
      if (lesson?.codeTemplate != null) {
        _codeController.text = lesson!.codeTemplate!.replaceAll(r'\n', '\n');
      }
      _isCompleted = lesson?.isCompleted ?? false;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<Object> _executePythonCode(String code) async {
    if (kIsWeb) {
      return await _executePythonOnline(code);
    } else {
      return await pythonBridge!.runCode(code);
    }
  }

  Future<String> _executePythonOnline(String code) async {
    try {
      final response = await http.post(
        Uri.parse('https://emkc.org/api/v2/piston/execute'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'language': 'python',
          'version': '3.10.0',
          'files': [
            {
              'content': code,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final output = result['run']['output'] ?? '';
        final stderr = result['run']['stderr'] ?? '';
        return stderr.isEmpty ? output : 'Error: $stderr';
      } else {
        return 'Error: Failed to execute code (${response.statusCode})';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _runPythonCode() async {
    setState(() {
      _isRunning = true;
      _output = '';
    });

    try {
      final lesson = ref.read(lessonsProvider).currentLesson;
      if (lesson == null) return;

      final result = await _executePythonCode(_codeController.text);
      
      setState(() {
        _output = result.toString();
      });

      // Compare output with expected output
      final expectedOutput = lesson.expectedOutput?.trim() ?? '';
      final actualOutput = result.toString().trim();

      if (actualOutput == expectedOutput) {
        // Code is correct, complete the lesson
        await ref.read(lessonsProvider.notifier).completeCurrentLesson();
        
        setState(() {
          _isCompleted = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Lesson completed! +${lesson.xpReward} XP',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Output doesn\'t match expected result. Try again!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error running code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _handleNextLesson() {
    Navigator.pop(context);
    // The lessons screen will automatically show the next lesson
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
          if (_isCompleted)
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
                  // Output Display
                  if (_output.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        border: Border(
                          top: BorderSide(color: AppColors.surfaceVariant),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.terminal, size: 16, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Output:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _output,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
                    onPressed: () async {
                      final lessonsState = ref.read(lessonsProvider);
                      final authState = ref.read(authProvider);
                      final lesson = lessonsState.currentLesson;

                      if (lesson == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No lesson loaded to show a hint.'),
                          ),
                        );
                        return;
                      }

                      final languageCode =
                          authState.user?.languagePreference ?? 'en';

                      final LessonsRepository lessonsRepository =
                          getIt<LessonsRepository>();

                      // Fetch hints for the current lesson
                      final Either<dynamic, List<LessonHint>> result =
                          await lessonsRepository.getHintsByLesson(lesson.id);

                      result.fold(
                        (_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to load hint. Please try again.'),
                            ),
                          );
                        },
                        (hints) {
                          if (hints.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No hints available for this lesson yet.'),
                              ),
                            );
                            return;
                          }

                          final hintText =
                              hints.first.getHintText(languageCode);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('💡 Hint: $hintText'),
                              duration: const Duration(seconds: 8),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('Hint'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      side: const BorderSide(color: AppColors.warning),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning
                        ? null
                        : (_isCompleted ? _handleNextLesson : _runPythonCode),
                    icon: _isRunning
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
                        : Icon(_isCompleted ? Icons.arrow_forward : Icons.play_arrow),
                    label: Text(_isCompleted ? 'Next' : 'Run Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
      if (match.start > lastMatchEnd) {
        final normalText = content.substring(lastMatchEnd, match.start);
        spans.addAll(_highlightQuotes(normalText));
      }

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
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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