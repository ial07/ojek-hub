import 'package:get/get.dart';
import 'package:KerjoCurup/modules/auth/auth_controller.dart';
import '../../home_employer/bindings/home_employer_binding.dart';
import '../../home_worker/bindings/home_worker_binding.dart';
import '../../profile/bindings/profile_binding.dart';

class MainController extends GetxController {
  AuthController get authController => Get.find<AuthController>();
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Wait for Auth to be ready before initializing specific home dependencies
    if (authController.isReady.value) {
      _initDependencies();
    } else {
      // If not ready (fresh start?), listen once
      once(authController.isReady, (_) {
        _initDependencies();
      });
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void _initDependencies() {
    print('[MAIN] Initializing dependencies. Role: ${authController.userRole}');

    // Inject Profile Dependencies
    ProfileBinding().dependencies();

    // Inject Home Dependencies based on Role
    final role = authController.userRole;
    if (role == 'worker') {
      HomeWorkerBinding().dependencies();
    } else {
      HomeEmployerBinding().dependencies();
    }
  }

  bool get isWorker => authController.userRole == 'worker';
}
