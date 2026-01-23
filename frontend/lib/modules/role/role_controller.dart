import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/api/api_client.dart';
import '../../routes.dart';

/// RoleController - Handles role selection with null safety
class RoleController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final box = GetStorage();

  // State flags
  var isLoading = false.obs;
  var isReady = false.obs;

  // Nullable session data
  String? email;
  String? name;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() {
    print('[ROLE] Initializing...');

    // Check Supabase session
    final session = _supabase.auth.currentSession;

    if (session == null) {
      print('[ROLE] No session, redirecting to login');
      Get.offAllNamed(Routes.login);
      return;
    }

    // Get user data from session
    email = session.user.email;
    name = session.user.userMetadata?['full_name'] as String? ??
        box.read('name') ??
        email?.split('@')[0];

    print('[ROLE] Session valid, email: $email');
    isReady.value = true;
  }

  void selectRole(String role) {
    if (!isReady.value) {
      print('[ROLE] Not ready, blocking role selection');
      return;
    }

    if (isLoading.value) {
      print('[ROLE] Already loading, blocking');
      return;
    }

    print('[ROLE] Selected role: $role');

    if (role == 'worker') {
      Get.toNamed(Routes.workerType);
    } else {
      submitRole(role, null);
    }
  }

  void selectWorkerType(String type) {
    if (!isReady.value || isLoading.value) {
      print('[ROLE] Blocked: ready=$isReady loading=$isLoading');
      return;
    }

    print('[ROLE] Selected worker type: $type');
    submitRole('worker', type);
  }

  Future<void> submitRole(String role, String? workerType) async {
    // Guard: not ready
    if (!isReady.value) {
      print('[ROLE] Not ready, blocking submit');
      return;
    }

    // Guard: already loading
    if (isLoading.value) {
      print('[ROLE] Already loading, blocking submit');
      return;
    }

    // Guard: email required
    final emailValue = email;
    if (emailValue == null || emailValue.isEmpty) {
      print('[ROLE] No email, blocking submit');
      Get.snackbar('Error', 'Data sesi tidak lengkap');
      return;
    }

    try {
      isLoading.value = true;
      print('[ROLE] Submitting role: $role, workerType: $workerType');

      final response = await _apiClient.dio.post('/auth/register', data: {
        'email': email,
        'name': name ?? email?.split('@')[0] ?? 'User',
        'role': role,
        'workerType': workerType,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        if (data['user'] != null) {
          await box.write('user', data['user']);
          print('[ROLE] User saved, redirecting');
          _redirect(role);
        } else {
          print('[ROLE] No user in response');
          Get.snackbar('Error', 'Gagal menyimpan data');
        }
      }
    } catch (e) {
      print('[ROLE] Submit error: $e');
      Get.snackbar('Error', 'Gagal menyimpan data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _redirect(String role) {
    if (role == 'worker') {
      Get.offAllNamed(Routes.homeWorker);
    } else {
      Get.offAllNamed(Routes.homeEmployer);
    }
  }
}
