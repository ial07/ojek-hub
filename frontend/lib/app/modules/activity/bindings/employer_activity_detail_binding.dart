import 'package:get/get.dart';
import '../controllers/employer_activity_detail_controller.dart';

class EmployerActivityDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployerActivityDetailController>(
      () => EmployerActivityDetailController(),
    );
  }
}
