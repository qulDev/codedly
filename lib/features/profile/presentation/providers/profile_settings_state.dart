import 'package:equatable/equatable.dart';

class ProfileSettingsState extends Equatable {
  final String displayName;
  final String initialDisplayName;
  final ProfileSettingsStatus status;
  final String? errorMessage;

  const ProfileSettingsState({
    required this.displayName,
    required this.initialDisplayName,
    this.status = ProfileSettingsStatus.idle,
    this.errorMessage,
  });

  factory ProfileSettingsState.initial(String initialDisplayName) {
    return ProfileSettingsState(
      displayName: initialDisplayName,
      initialDisplayName: initialDisplayName,
    );
  }

  bool get hasChanges => displayName.trim() != initialDisplayName.trim();

  bool get canSubmit => displayName.trim().isNotEmpty && hasChanges;

  ProfileSettingsState copyWith({
    String? displayName,
    String? initialDisplayName,
    ProfileSettingsStatus? status,
    String? errorMessage,
  }) {
    return ProfileSettingsState(
      displayName: displayName ?? this.displayName,
      initialDisplayName: initialDisplayName ?? this.initialDisplayName,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    initialDisplayName,
    status,
    errorMessage,
  ];
}

enum ProfileSettingsStatus { idle, saving, success, error }
