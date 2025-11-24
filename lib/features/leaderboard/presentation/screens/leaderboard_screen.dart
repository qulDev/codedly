import 'package:codedly/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:codedly/core/l10n/generated/app_localizations.dart';
import 'package:codedly/core/theme/colors.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';
import 'package:codedly/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:codedly/features/leaderboard/presentation/providers/leaderboard_state.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final leaderboardState = ref.watch(leaderboardProvider);
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(leaderboardProvider.notifier).refreshLeaderboard(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(leaderboardProvider.notifier).refreshLeaderboard(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _LeaderboardIntro(l10n: l10n),
            const SizedBox(height: 16),
            ..._buildContent(
              context,
              l10n,
              leaderboardState,
              currentUserId,
              onRetry: () =>
                  ref.read(leaderboardProvider.notifier).loadLeaderboard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    LeaderboardState state,
    String? currentUserId, {
    required VoidCallback onRetry,
  }) {
    if (state.status == LeaderboardStatus.loading && state.entries.isEmpty) {
      return const [_LoadingPlaceholder()];
    }

    if (state.status == LeaderboardStatus.error && state.entries.isEmpty) {
      return [
        _ErrorPlaceholder(
          message: state.errorMessage ?? l10n.networkError,
          onRetry: onRetry,
        ),
      ];
    }

    if (state.entries.isEmpty) {
      return [_EmptyPlaceholder(message: l10n.leaderboardEmpty)];
    }

    final widgets = <Widget>[];

    if (state.status == LeaderboardStatus.error) {
      widgets.add(
        _InlineErrorBanner(message: state.errorMessage ?? l10n.networkError),
      );
      widgets.add(const SizedBox(height: 12));
    }

    for (final entry in state.entries) {
      widgets.add(
        _LeaderboardTile(
          entry: entry,
          isCurrentUser: entry.userId == currentUserId,
          l10n: l10n,
        ),
      );
      widgets.add(const SizedBox(height: 12));
    }

    if (state.status == LeaderboardStatus.loading) {
      widgets.add(const _LoadingMoreIndicator());
    }

    return widgets;
  }
}

class _LeaderboardIntro extends StatelessWidget {
  const _LeaderboardIntro({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppColors.xpGold),
              const SizedBox(width: 8),
              Text(
                l10n.leaderboard,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.leaderboardSubtitle,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.leaderboardTieBreaker,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.entry,
    required this.isCurrentUser,
    required this.l10n,
  });

  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd(
      l10n.localeName,
    ).add_Hm().format(entry.xpReachedAt.toLocal());
    final backgroundColor = isCurrentUser
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.surface;
    final borderColor = isCurrentUser
        ? AppColors.primary
        : AppColors.surfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _RankBadge(rank: entry.rank),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.totalXp} ${l10n.xp}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.xpGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.level} ${entry.currentLevel} • ${entry.lessonsCompleted} ${l10n.lessons.toLowerCase()}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.streakCount} ${l10n.days} ${l10n.streak.toLowerCase()} • $dateText',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = AppColors.xpGold;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = AppColors.secondary;
        icon = Icons.emoji_events_outlined;
        break;
      case 3:
        badgeColor = AppColors.levelBadge;
        icon = Icons.emoji_events_outlined;
        break;
      default:
        badgeColor = AppColors.surfaceVariant;
        icon = null;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: badgeColor, size: 24)
          : Text(
              '#$rank',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Align(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off, color: AppColors.error.withValues(alpha: 0.8)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
