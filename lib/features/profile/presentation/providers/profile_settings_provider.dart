import 'package:codedly/core/di/injection.dart';
import 'package:codedly/features/auth/domain/repositories/auth_repository.dart';
import 'package:codedly/features/auth/presentation/providers/auth_provider.dart';
import 'package:codedly/features/profile/presentation/providers/profile_settings_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSettingsNotifier extends StateNotifier<ProfileSettingsState> {
  ProfileSettingsNotifier({
    required String initialDisplayName,
    required AuthRepository authRepository,
    required Ref ref,
  }) : _authRepository = authRepository,
       _ref = ref,
       super(ProfileSettingsState.initial(initialDisplayName));

  final AuthRepository _authRepository;
  final Ref _ref;

  void updateDisplayName(String value) {
    if (state.displayName == value) return;
    state = state.copyWith(
      displayName: value,
      status: ProfileSettingsStatus.idle,
      errorMessage: null,
    );
  }

  Future<void> saveChanges() async {
    final trimmedName = state.displayName.trim();
    if (!state.canSubmit) return;

    state = state.copyWith(
      status: ProfileSettingsStatus.saving,
      errorMessage: null,
    );

    final result = await _authRepository.updateProfile(
      displayName: trimmedName,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ProfileSettingsStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(
          status: ProfileSettingsStatus.success,
          displayName: trimmedName,
          initialDisplayName: trimmedName,
          errorMessage: null,
        );
        // Refresh aut profider status
        _ref.read(authProvider.notifier).checkAuthStatus();
      },
    );
  }

  void dismissMessage() {
    if (state.status == ProfileSettingsStatus.success ||
        state.status == ProfileSettingsStatus.error) {
      state = state.copyWith(
        status: ProfileSettingsStatus.idle,
        errorMessage: null,
      );
    }
  }
}

final profileSettingsProvider =
    StateNotifierProvider.autoDispose<
      ProfileSettingsNotifier,
      ProfileSettingsState
    >((ref) {
      final authState = ref.read(authProvider);
      final initialName = authState.user?.displayName?.trim() ?? '';
      return ProfileSettingsNotifier(
        initialDisplayName: initialName,
        authRepository: getIt<AuthRepository>(),
        ref: ref,
      );
    });
