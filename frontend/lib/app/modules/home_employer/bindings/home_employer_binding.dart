import 'package:get/get.dart';
import '../controllers/home_employer_controller.dart';

class HomeEmployerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeEmployerController>(() => HomeEmployerController());
  }
}
