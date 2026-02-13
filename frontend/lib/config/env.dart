class Env {
  // Replace with your local machine's IP for Android Emulator (10.0.2.2 usually)
  // or your computer's IP if testing on real device
  static String get baseApiUrl {
    // // If running on Android Emulator, use 10.0.2.2 to access host machine
    // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    //   return 'http://10.0.2.2:3000/api';
    // }
    // // For iOS Simulator and Web, localhost is fine
    // return 'http://localhost:3000/api';

    // // Switch to this for production:
    return 'https://ojek-hub.vercel.app/api';
  }

  // Web Client ID from Firebase (client_type: 3 in google-services.json)
  // Required to get idToken for backend verification
  static const String googleWebClientId =
      '1080029274310-6dvi1fj8eqgh6ho39961m4lvbqbugj1o.apps.googleusercontent.com';

  // Verified App Links Domain
  static const String appLinksDomain = 'kerjocurup-link.vercel.app';

  // Play Store URL for fallbacks
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.kerjocurup.app'; // Fixed ID
}
