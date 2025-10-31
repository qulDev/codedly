import 'package:equatable/equatable.dart';
import 'package:codedly/features/stats/domain/entities/user_stats.dart';

/// State for user statistics.
class StatsState extends Equatable {
  final StatsStatus status;
  final UserStats? stats;
  final String? errorMessage;

  const StatsState({
    this.status = StatsStatus.initial,
    this.stats,
    this.errorMessage,
  });

  StatsState copyWith({
    StatsStatus? status,
    UserStats? stats,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, errorMessage];
}

/// Status values for [StatsState].
enum StatsStatus {
  /// Initial state, no data loaded yet.
  initial,

  /// Loading stats from the server.
  loading,

  /// Stats loaded successfully.
  loaded,

  /// An error occurred while loading stats.
  error,
}
