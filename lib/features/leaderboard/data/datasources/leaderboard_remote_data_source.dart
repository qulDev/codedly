import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:codedly/core/errors/exceptions.dart' as app_exceptions;
import 'package:codedly/features/leaderboard/data/models/leaderboard_entry_model.dart';

@lazySingleton
class LeaderboardRemoteDataSource {
  final SupabaseClient _client;

  LeaderboardRemoteDataSource(this._client);

  Future<List<LeaderboardEntryModel>> fetchLeaderboard({int limit = 50}) async {
    try {
      final response = await _client.rpc(
        'get_leaderboard',
        params: {'limit_count': limit},
      );

      final data = List<Map<String, dynamic>>.from(
        (response as List?) ?? const [],
      );

      return data
          .map((json) => LeaderboardEntryModel.fromJson(json))
          .toList(growable: false);
    } catch (e) {
      throw app_exceptions.ServerException(e.toString());
    }
  }
}
