import 'package:get/get.dart';
import '../controllers/create_job_controller.dart';

class CreateJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateJobController>(() => CreateJobController());
  }
}
