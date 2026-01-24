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
  var isEmployerExpanded = false.obs; // Added for UI state

  // Checking state
  bool get isWorker => selectedRole.value == 'worker';

  // Worker no longer needs to select type explicitly in Onboarding first step
  // They just select "Pencari Kerja" (worker)
  bool get isReadyToSubmitProfile => selectedRole.isNotEmpty;

  Future<void> register(String name, String phone, String location) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Get.snackbar('Error', 'Sesi kadaluarsa, silakan login ulang.');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Default workerType to 'all' if not specified for worker, or leave null to let backend handle
      // The requirement says "Worker role can apply for ojek jobs AND daily worker jobs"
      // So sending 'all' or specific value that backend understands is good.
      // We'll set it to 'all' or null. Let's strictly follow backend needs.
      // Backend expects 'daily', 'ojek' or potentially null/all.
      // We will send 'all' if selectedWorkerType is empty but role is worker.

      String? finalWorkerType;
      if (isWorker) {
        finalWorkerType = selectedWorkerType.value.isNotEmpty
            ? selectedWorkerType.value
            : 'all';
      }

      // Call Backend Register API
      final response = await _apiClient.dio.post('/auth/register', data: {
        'token': session.accessToken,
        'name': name,
        'phone': phone,
        'location': location,
        'role': selectedRole.value,
        'workerType': finalWorkerType,
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
