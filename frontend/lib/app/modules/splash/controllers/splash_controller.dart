import 'package:get/get.dart';
import '../../../../modules/auth/auth_controller.dart';
import 'package:KerjoCurup/app/routes/app_routes.dart';

/// SplashController - Visual only, no auth logic
/// Splash should only show a brief loading animation
class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _startLaunchSequence();
  }

  Future<void> _startLaunchSequence() async {
    print('[SPLASH] Splash init start');

    // 1. Minimum Splash Display Time
    await Future.delayed(const Duration(seconds: 2));

    try {
      print('[SPLASH] Delegating to AuthController...');
      // 2. Delegate to Auth Logic
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        auth.handleAppLaunch();
      } else {
        print('[SPLASH] AuthController not found! Force Login.');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // 3. Safety Fallback Timer (Max 3 seconds after wait)
      Future.delayed(const Duration(seconds: 3), () {
        // Check if we are still on Splash
        if (Get.currentRoute == Routes.SPLASH) {
          print('[SPLASH] Fallback triggered: Forcing navigation to Login');
          Get.offAllNamed(Routes.LOGIN);
        }
      });
    } catch (e) {
      print('[SPLASH] Critical Error: $e');
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
