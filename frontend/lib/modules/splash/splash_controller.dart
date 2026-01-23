import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes.dart';

class SplashController extends GetxController {
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Wait for splash animation
    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if user is logged in
    final token = box.read('token');
    final user = box.read('user');

    if (token != null && user != null) {
      // User is logged in - redirect to dashboard based on role
      final role = user['role'] ?? '';
      if (role == 'worker') {
        Get.offAllNamed(Routes.homeWorker);
      } else if (role == 'farmer' || role == 'warehouse') {
        Get.offAllNamed(Routes.homeEmployer);
      } else {
        // Role not set - go to role selection
        Get.offAllNamed(Routes.role);
      }
    } else {
      // Not logged in - go to login
      Get.offAllNamed(Routes.login);
    }
  }
}
