/// API and environment constants
class ApiConstants {
  ApiConstants._();

  /// Supabase configuration
  /// These should be loaded from environment variables
  static const String supabaseUrlKey = 'SUPABASE_URL';
  static const String supabaseAnonKeyKey = 'SUPABASE_ANON_KEY';

  /// API endpoints (relative to Supabase URL)
  static const String authEndpoint = '/auth/v1';
  static const String restEndpoint = '/rest/v1';
  static const String storageEndpoint = '/storage/v1';

  /// Table names
  static const String usersTable = 'users';
  static const String lessonsTable = 'lessons';
  static const String quizzesTable = 'quizzes';
  static const String userProgressTable = 'user_progress';
  static const String userStatsTable = 'user_stats';
  static const String leaderboardTable = 'leaderboard';

  /// Storage buckets
  static const String profilePicturesBucket = 'profile_pictures';
  static const String lessonAssetsBucket = 'lesson_assets';

  /// Request timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
