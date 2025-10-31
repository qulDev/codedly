import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codedly/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:codedly/core/l10n/generated/app_localizations.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/auth/presentation/providers/auth_state.dart';
import 'package:codedly/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:codedly/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:codedly/features/home/presentation/screens/home_screen.dart';
import 'package:codedly/shared/widgets/loading_indicator.dart';

/// The root widget of the Codedly application.
///
/// This widget sets up the MaterialApp with theme, localization,
/// and routing configuration.
class CodedlyApp extends ConsumerWidget {
  const CodedlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Codedly',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Indonesian
      ],

      // Home screen with auth routing
      home: const AuthGate(),
    );
  }
}

/// Auth gate to handle routing based on authentication state
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.initial ||
      AuthStatus.loading => const Scaffold(body: LoadingIndicator()),
      AuthStatus.authenticated => _buildAuthenticatedRoute(authState),
      AuthStatus.unauthenticated || AuthStatus.error => const SignInScreen(),
    };
  }

  Widget _buildAuthenticatedRoute(AuthState authState) {
    final user = authState.user;
    if (user == null) return const SignInScreen();

    // Show onboarding if not completed
    if (!user.onboardingCompleted) {
      return const OnboardingScreen();
    }

    // Show home screen
    return const HomeScreen();
  }
}
