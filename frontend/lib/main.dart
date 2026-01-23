import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/routes/app_routes.dart';
import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'app.dart';
import 'app/services/auth_service.dart';
import 'modules/auth/auth_controller.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase (single auth provider)
    await Supabase.initialize(
      url: 'https://axkytghthxibjahztvpj.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF4a3l0Z2h0aHhpYmphaHp0dnBqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MjE2MzksImV4cCI6MjA4NDM5NzYzOX0.glqruWet2NYqqwZVuD2T9SBU_cS1EZC3K8xvOS3MTQI',
    );

    // Initialize GetStorage
    await GetStorage.init();

    // Dependency Injection - Must be before auth listener
    Get.put(ApiClient());
    await Get.find<ApiClient>().init();
    Get.put(AuthController());
    Get.put(AuthService());

    // Listen for deep link OAuth callbacks (critical for mobile)
    // This triggers AFTER OAuth returns via deep link
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('[MAIN] Auth state changed: ${data.event}');
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        print('[MAIN] Session detected, calling AuthController...');
        // Get AuthController and process session
        if (Get.isRegistered<AuthController>()) {
          final authController = Get.find<AuthController>();
          // Force reset the session check flag and process again
          authController.processSessionFromDeepLink(data.session!);
        }
      }
    });

    // Run the app
    runApp(const OjekHubApp());
  } catch (e, stackTrace) {
    print('Fatal error during app initialization: $e');
    print('Stack trace: $stackTrace');
    // Still try to run the app even if init partially fails
    runApp(MaterialApp(
      title: 'OjekHub',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.SPLASH,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
