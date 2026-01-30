import 'package:get/get.dart';
import '../../../../routes.dart';
import '../../../../core/api/api_client.dart';
import '../../../../modules/auth/auth_controller.dart'; // Correct import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:KerjoCurup/app/modules/main/views/main_view.dart';
import 'package:KerjoCurup/app/modules/main/bindings/main_binding.dart';
import 'package:KerjoCurup/app/modules/main/views/main_view.dart';
import 'package:KerjoCurup/app/modules/main/bindings/main_binding.dart';

import 'package:KerjoCurup/app/modules/main/views/main_view.dart';
import 'package:KerjoCurup/app/modules/main/bindings/main_binding.dart';

class OnboardingController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final AuthController _authController = Get.find<AuthController>();

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

      // Success - persist user data and update all auth state
      final userData = response.data['user'];

      // CRITICAL FIX: Explicitly update AuthController state synchronously
      // This ensures MainController sees the correct role immediately
      await _authController.setUserData(userData);

      // NAVIGATION FIX: Use explicit widget navigation to guarantee MainView shell
      // bypassing any potential route alias issues or middleware interference
      Get.offAll(() => const MainView(), binding: MainBinding());
    } catch (e) {
      Get.snackbar('Registrasi Gagal', e.toString());
      print(e);
    }
  }
}
