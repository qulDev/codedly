import 'package:equatable/equatable.dart';
import 'package:codedly/features/leaderboard/domain/entities/leaderboard_entry.dart';

/// Holds leaderboard entries and their loading status.
class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final List<LeaderboardEntry> entries;
  final String? errorMessage;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    List<LeaderboardEntry>? entries,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}

/// Represents the lifecycle of fetching leaderboard data.
enum LeaderboardStatus { initial, loading, loaded, error }
