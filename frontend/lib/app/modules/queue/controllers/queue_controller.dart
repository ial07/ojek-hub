import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class QueueController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  String orderId = '';
  var queueList =
      <dynamic>[].obs; // Using dynamic or QueueModel with extra user data
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is String) {
      orderId = Get.arguments;
    } else {
      print(
          '[QueueController] Invalid argument type: ${Get.arguments?.runtimeType}');
      Get.snackbar('Error', 'Data antrian tidak valid');
      Get.back();
      return;
    }

    if (orderId.isEmpty) {
      Get.snackbar('Error', 'ID lowongan tidak ditemukan');
      Get.back();
      return;
    }

    fetchQueue();
  }

  Future<void> fetchQueue() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/orders/$orderId/queue');
      if (response.statusCode == 200) {
        // Response data['data'] contains list with joined user info
        queueList.value = response.data['data'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat antrian');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeWorker(String userId) async {
    // Employer removing worker? (Not explicitly in MVP backend, backend has leaveQueue for self)
    // Actually Backend `DELETE /orders/:orderId/queue` calls `leaveQueue` which does `delete().eq(worker_id, auth.uid())`.
    // So Employer CANNOT remove worker via that endpoint directly unless logic allows.
    // My backend logic in Step 6: `leaveQueue(userId...)`. If userId comes from token, it's self-removal.
    // Employer removal was not explicitly implemented in Step 6 backend `QueueService`.
    // It says "Employer sees queue... Worker leaves".
    // So sticking to MVP: Employer just VIEWS. Worker LEAVES.
    // So QueueView is Read-Only for Employer.
  }

  Future<void> openWhatsApp(String phone) async {
    if (phone.isEmpty) return;

    final url = 'https://wa.me/$phone';
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp');
    }
  }
}
