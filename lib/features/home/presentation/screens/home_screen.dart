import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/l10n/generated/app_localizations.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/stats/presentation/providers/stats_provider.dart';
import 'package:codedly/features/stats/presentation/providers/stats_state.dart';
import 'package:codedly/features/lessons/presentation/providers/lessons_provider.dart';
import 'package:codedly/features/lessons/presentation/screens/modules_screen.dart';
import 'package:codedly/features/profile/presentation/screens/profile_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final statsState = ref.watch(statsProvider);
    final lessonsState = ref.watch(lessonsProvider);
    final user = authState.user;
    final languageCode = user?.languagePreference ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(statsProvider.notifier).refreshStats();
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppColors.background,
                elevation: 0,
                floating: true,
                title: Row(
                  children: [
                    Icon(Icons.code, color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Welcome message
                    Text(
                      'Welcome back, ${user?.displayName ?? 'Learner'}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.stars,
                            label: l10n.xp,
                            value: statsState.status == StatsStatus.loaded
                                ? '${statsState.stats?.totalXp ?? 0}'
                                : '...',
                            color: AppColors.xpGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_up,
                            label: l10n.level,
                            value: statsState.status == StatsStatus.loaded
                                ? '${statsState.stats?.currentLevel ?? 1}'
                                : '...',
                            color: AppColors.levelBadge,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            label: l10n.streak,
                            value: statsState.status == StatsStatus.loaded
                                ? '${statsState.stats?.streakCount ?? 0}'
                                : '...',
                            color: AppColors.streakFire,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Continue Learning Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Continue Learning',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ModulesScreen(),
                              ),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Show first module or placeholder
                    if (lessonsState.modules.isNotEmpty)
                      _LessonModuleCard(
                        title: lessonsState.modules.first.getTitle(
                          languageCode,
                        ),
                        description:
                            lessonsState.modules.first.getDescription(
                              languageCode,
                            ) ??
                            '',
                        lessonsCompleted:
                            lessonsState.modules.first.lessonsCompleted,
                        totalLessons: lessonsState.modules.first.totalLessons,
                        difficulty: lessonsState.modules.first.difficultyLevel,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModulesScreen(),
                            ),
                          );
                        },
                      )
                    else
                      _LessonModuleCard(
                        title: 'Introduction to Python',
                        description: 'Learn the basics of Python programming',
                        lessonsCompleted: 0,
                        totalLessons: 2,
                        difficulty: 'Beginner',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ModulesScreen(),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),

                    // Coming Soon Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.construction,
                            size: 48,
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'More Modules Coming Soon!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We\'re working on more Python lessons and quizzes for you.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.lessons,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.quiz),
            label: l10n.practice,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: l10n.leaderboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ModulesScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tab ${index + 1} coming soon! 🚀')),
            );
          }
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _LessonModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final int lessonsCompleted;
  final int totalLessons;
  final String difficulty;
  final VoidCallback onTap;

  const _LessonModuleCard({
    required this.title,
    required this.description,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.difficulty,
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
                  label: Text(difficulty, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: AppColors.primary),
                ),
                Icon(Icons.arrow_forward, color: AppColors.textSecondary),
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
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
                  style: TextStyle(
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
