import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/lessons/presentation/screens/modules_screen.dart';
import 'package:codedly/features/profile/presentation/providers/profile_settings_provider.dart';
import 'package:codedly/features/profile/presentation/providers/profile_settings_state.dart';
import 'package:codedly/features/stats/presentation/providers/stats_provider.dart';
import 'package:codedly/features/stats/presentation/providers/stats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(profileSettingsProvider);
    _nameController = TextEditingController(text: initialState.displayName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileSettingsState>(profileSettingsProvider, (prev, next) {
      if (!mounted) return;
      if (prev?.status != ProfileSettingsStatus.success &&
          next.status == ProfileSettingsStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Display name updated')));
        ref.read(profileSettingsProvider.notifier).dismissMessage();
      } else if (prev?.status != ProfileSettingsStatus.error &&
          next.status == ProfileSettingsStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Failed to update profile'),
          ),
        );
        ref.read(profileSettingsProvider.notifier).dismissMessage();
      }
    });

    final profileState = ref.watch(profileSettingsProvider);
    final authState = ref.watch(authProvider);
    final statsState = ref.watch(statsProvider);
    final user = authState.user;

    if (_nameController.text != profileState.displayName) {
      _nameController.value = _nameController.value.copyWith(
        text: profileState.displayName,
        selection: TextSelection.collapsed(
          offset: profileState.displayName.length,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Sign out',
        child: const Icon(Icons.logout),
        onPressed: () => ref.read(authProvider.notifier).signOut(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await Future.wait([
            ref.read(statsProvider.notifier).refreshStats(),
            ref.read(authProvider.notifier).checkAuthStatus(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _ProfileHeader(
              userName: user?.displayName ?? 'Learner',
              email: user?.email ?? '-',
              language: user?.languagePreference ?? 'en',
              createdAt: user?.createdAt,
            ),
            const SizedBox(height: 20),
            _StatsGrid(statsState: statsState),
            const SizedBox(height: 32),
            Text(
              'Account',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              onChanged: ref
                  .read(profileSettingsProvider.notifier)
                  .updateDisplayName,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Display name',
                hintText: 'What should we call you?',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed:
                  profileState.canSubmit &&
                      profileState.status != ProfileSettingsStatus.saving
                  ? () =>
                        ref.read(profileSettingsProvider.notifier).saveChanges()
                  : null,
              icon: profileState.status == ProfileSettingsStatus.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(
                profileState.status == ProfileSettingsStatus.saving
                    ? 'Saving...'
                    : 'Save changes',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
            const SizedBox(height: 32),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? '-',
            ),
            _InfoTile(
              icon: Icons.calendar_today,
              label: 'Joined',
              value: user != null
                  ? '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}'
                  : '-',
            ),
            _InfoTile(
              icon: Icons.language,
              label: 'Language preference',
              value: user?.languagePreference.toUpperCase() ?? 'EN',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Practice'),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaderboardScreen(),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.userName,
    required this.email,
    required this.language,
    required this.createdAt,
  });

  final String userName;
  final String email;
  final String language;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final initials =
        (userName.isNotEmpty
                ? userName[0]
                : email.isNotEmpty
                ? email[0]
                : 'C')
            .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.language, size: 16),
                      label: Text(language.toUpperCase()),
                    ),
                    if (createdAt != null)
                      Chip(
                        avatar: const Icon(Icons.calendar_month, size: 16),
                        label: Text('Since ${createdAt!.year}'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.statsState});

  final StatsState statsState;

  @override
  Widget build(BuildContext context) {
    final stats = statsState.stats;
    final items = [
      _StatItem(
        icon: Icons.stars,
        label: 'XP',
        value: stats?.totalXp.toString() ?? '--',
        color: AppColors.xpGold,
      ),
      _StatItem(
        icon: Icons.trending_up,
        label: 'Level',
        value: stats?.currentLevel.toString() ?? '--',
        color: AppColors.levelBadge,
      ),
      _StatItem(
        icon: Icons.local_fire_department,
        label: 'Streak',
        value: stats?.streakCount.toString() ?? '--',
        color: AppColors.streakFire,
      ),
      _StatItem(
        icon: Icons.menu_book,
        label: 'Lessons',
        value: stats?.lessonsCompleted.toString() ?? '--',
        color: AppColors.secondary,
      ),
      _StatItem(
        icon: Icons.quiz,
        label: 'Quizzes',
        value: stats?.quizzesCompleted.toString() ?? '--',
        color: AppColors.primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress overview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (statsState.status == StatsStatus.loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 24,
                  child: _StatCard(item: item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: item.color),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: item.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
