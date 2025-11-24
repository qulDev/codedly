import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/di/injection.dart';
import 'package:codedly/features/leaderboard/domain/usecases/get_leaderboard.dart';
import 'package:codedly/features/leaderboard/presentation/providers/leaderboard_state.dart';

/// Manages leaderboard loading/refresh logic.
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier({required this.getLeaderboardUseCase})
    : super(const LeaderboardState()) {
    loadLeaderboard();
  }

  final GetLeaderboard getLeaderboardUseCase;

  Future<void> loadLeaderboard({int limit = 50}) async {
    state = state.copyWith(
      status: LeaderboardStatus.loading,
      clearErrorMessage: true,
    );

    final result = await getLeaderboardUseCase(
      GetLeaderboardParams(limit: limit),
    );

    state = result.fold(
      (failure) => state.copyWith(
        status: LeaderboardStatus.error,
        errorMessage: failure.message,
      ),
      (entries) => state.copyWith(
        status: LeaderboardStatus.loaded,
        entries: entries,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> refreshLeaderboard() => loadLeaderboard();
}

final leaderboardProvider =
    StateNotifierProvider.autoDispose<LeaderboardNotifier, LeaderboardState>((
      ref,
    ) {
      return LeaderboardNotifier(
        getLeaderboardUseCase: getIt<GetLeaderboard>(),
      );
    });
