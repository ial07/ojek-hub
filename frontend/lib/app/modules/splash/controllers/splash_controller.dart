import 'package:get/get.dart';
import 'package:ojekhub_mobile/app/routes/app_routes.dart';

/// SplashController - Visual only, no auth logic
/// Splash should only show a brief loading animation
class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Simulate loading/initialization
    Future.delayed(const Duration(seconds: 2), () {
      Get.offNamed(Routes.LANDING); // Navigate to Landing
    });
  }
}
