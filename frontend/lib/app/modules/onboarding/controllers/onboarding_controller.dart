import 'package:get/get.dart';
import '../../../../routes.dart';
import '../../../../core/api/api_client.dart';
import '../../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AuthService _authService = Get.find<AuthService>();

  // State
  var selectedRole = ''.obs;
  var selectedWorkerType = ''.obs;
  
  // Checking state
  bool get isWorker => selectedRole.value == 'worker';
  bool get isReadyToSubmitProfile => selectedRole.isNotEmpty && (selectedRole.value != 'worker' || selectedWorkerType.isNotEmpty);

  Future<void> register(String name, String phone, String location) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Get.snackbar('Error', 'Sesi kadaluarsa, silakan login ulang.');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Call Backend Register API
      final response = await _apiClient.dio.post('/auth/register', data: {
        'token': session.accessToken, // Or confirm authentication simply by Bearer header
        'name': name,
        'phone': phone,
        'location': location,
        'role': selectedRole.value,
        'workerType': isWorker ? selectedWorkerType.value : null,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success
        _authService.userProfile.value = response.data['user'];
        
        if (isWorker) {
          Get.offAllNamed(Routes.HOME_WORKER);
        } else {
          Get.offAllNamed(Routes.HOME_EMPLOYER);
        }
      }
    } catch (e) {
      Get.snackbar('Registrasi Gagal', e.toString());
      print(e);
    }
  }
}
