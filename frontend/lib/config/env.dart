import 'package:flutter/foundation.dart';

class Env {
  // Replace with your local machine's IP for Android Emulator (10.0.2.2 usually)
  // or your computer's IP if testing on real device
  static String get baseApiUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    return 'http://10.0.2.2:3000/api';
  }

  // Web Client ID from Firebase (client_type: 3 in google-services.json)
  // Required to get idToken for backend verification
  static const String googleWebClientId =
      '1080029274310-6dvi1fj8eqgh6ho39961m4lvbqbugj1o.apps.googleusercontent.com';
}
