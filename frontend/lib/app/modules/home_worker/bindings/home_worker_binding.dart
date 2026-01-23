import 'package:get/get.dart';
import '../controllers/home_worker_controller.dart';

class HomeWorkerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeWorkerController>(() => HomeWorkerController());
  }
}
