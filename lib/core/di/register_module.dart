import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Injectable module for third-party dependencies
@module
abstract class RegisterModule {
  /// Provides Connectivity instance
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// Provides Supabase client instance
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
