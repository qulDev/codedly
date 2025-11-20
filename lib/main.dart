import 'package:codedly/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:codedly/app.dart';
import 'package:codedly/core/di/injection.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  // Load environment variables
  await dotenv.load();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final event = data.event;
  final session = data.session;

  print("🟢 SUPABASE AUTH EVENT → $event");
  print("📌 Session: ${session != null ? 'Available' : 'NULL'}");

    if (event == AuthChangeEvent.signedIn && session != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  });


  // Initialize dependency injection
  await configureDependencies();

  runApp(const ProviderScope(child: CodedlyApp()));
}
