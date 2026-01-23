import 'package:flutter/foundation.dart';

/// Platform-specific utilities for OAuth and deep linking
class PlatformUtils {
  /// Get the appropriate OAuth redirect URL based on platform
  static String getOAuthRedirectUrl() {
    if (kIsWeb) {
      // Web uses localhost redirect
      return 'http://localhost:8080';
    } else {
      // Mobile (Android/iOS) uses deep link scheme
      return 'ojekhub://login-callback';
    }
  }

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform
  static bool get isMobile => !kIsWeb;

  /// Get platform name for debugging
  static String get platformName {
    if (kIsWeb) return 'Web';
    return 'Mobile';
  }
}
