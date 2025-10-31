import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/di/injection.dart';
import 'package:codedly/core/usecases/usecase.dart';
import 'package:codedly/features/stats/domain/usecases/get_user_stats.dart';
import 'package:codedly/features/stats/presentation/providers/stats_state.dart';

/// Notifier for user statistics state.
class StatsNotifier extends StateNotifier<StatsState> {
  final GetUserStats getUserStatsUseCase;

  StatsNotifier({required this.getUserStatsUseCase})
    : super(const StatsState()) {
    loadStats();
  }

  /// Loads the user's statistics.
  Future<void> loadStats() async {
    state = state.copyWith(status: StatsStatus.loading);

    final result = await getUserStatsUseCase(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        status: StatsStatus.error,
        errorMessage: failure.message,
      ),
      (stats) =>
          state = state.copyWith(status: StatsStatus.loaded, stats: stats),
    );
  }

  /// Refreshes the user's statistics.
  Future<void> refreshStats() async {
    await loadStats();
  }
}

/// Provider for user statistics.
final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(getUserStatsUseCase: getIt<GetUserStats>());
});
