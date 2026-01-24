import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../activity/controllers/activity_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    Get.lazyPut<ActivityController>(
      () => ActivityController(),
    );
  }
}
