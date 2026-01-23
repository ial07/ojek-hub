import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  
  var name = ''.obs;
  var role = ''.obs;
  var workerType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    final user = box.read('user');
    if (user != null) {
      name.value = user['name'] ?? 'User';
      role.value = user['role'] ?? '-';
      workerType.value = user['worker_type'] ?? '-';
    }
  }

  Future<void> logout() async {
    // Clear Supabase Session
    await Supabase.instance.client.auth.signOut();
    
    // Clear Local Storage
    await box.erase();
    
    // Redirect to Login
    Get.offAllNamed(Routes.login);
  }
}
