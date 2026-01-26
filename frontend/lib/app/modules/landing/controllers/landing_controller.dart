import 'package:get/get.dart';
import 'package:KerjoCurup/app/routes/app_routes.dart';

class LandingController extends GetxController {
  void toLogin() {
    Get.toNamed(Routes.LOGIN);
  }

  void toRegister() {
    Get.toNamed(Routes.ROLE_SELECTION);
  }
}
