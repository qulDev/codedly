/// Validators for user input
class Validators {
  Validators._();

  /// Email validation regex
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Password must be at least 8 characters
  static const int _minPasswordLength = 8;

  /// Display name must be 2-30 characters
  static const int _minNameLength = 2;
  static const int _maxNameLength = 30;

  /// Validates email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return _emailRegex.hasMatch(email.trim());
  }

  /// Validates password strength
  /// Password must be at least 8 characters
  static bool isValidPassword(String password) {
    return password.length >= _minPasswordLength;
  }

  /// Validates display name
  /// Must be 2-30 characters and contain only letters, numbers, spaces, and underscores
  static bool isValidDisplayName(String name) {
    if (name.isEmpty) return false;
    final trimmed = name.trim();
    if (trimmed.length < _minNameLength || trimmed.length > _maxNameLength) {
      return false;
    }
    // Allow letters (including Indonesian), numbers, spaces, and underscores
    final nameRegex = RegExp(r'^[a-zA-Z0-9\s_]+$');
    return nameRegex.hasMatch(trimmed);
  }

  /// Gets email error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Invalid email format';
    return null;
  }

  /// Gets password error message
  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (!isValidPassword(password)) {
      return 'Password must be at least $_minPasswordLength characters';
    }
    return null;
  }

  /// Gets display name error message
  static String? getDisplayNameError(String name) {
    if (name.isEmpty) return 'Display name is required';
    final trimmed = name.trim();
    if (trimmed.length < _minNameLength) {
      return 'Display name must be at least $_minNameLength characters';
    }
    if (trimmed.length > _maxNameLength) {
      return 'Display name must be at most $_maxNameLength characters';
    }
    if (!isValidDisplayName(name)) {
      return 'Display name can only contain letters, numbers, spaces, and underscores';
    }
    return null;
  }
}
