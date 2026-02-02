import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployerActivityDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Data
  final applicants = <Map<String, dynamic>>[].obs;
  final orderData = <String, dynamic>{}.obs; // Basic job info
  var orderId = '';

  @override
  void onInit() {
    super.onInit();
    // Expect order ID or Order Object passed as arguments
    if (Get.arguments != null) {
      if (Get.arguments is Map) {
        // If passed as Map (sometimes happens with JSON)
        orderId = Get.arguments['id'];
        orderData.value = Get.arguments;
      } else {
        // If passed as Object (OrderModel)
        // We might need to handle OrderModel, but let's assume loose coupling or dynamic for now
        // Or better, cast it properly if we import OrderModel.
        try {
          orderId = Get.arguments.id;
          // We can't easily convert OrderModel to Map without toJson, assuming it has it or we just use ID.
          // Let's safe fetch by ID.
        } catch (e) {
          print('Error parsing arguments: $e');
        }
      }
    }

    if (orderId.isNotEmpty) {
      fetchApplicants();
      _fetchOrderDetails();
    }
  }

  Future<void> _fetchOrderDetails() async {
    // Re-fetch fresh data for quotas
    final response =
        await _supabase.from('orders').select('*').eq('id', orderId).single();
    orderData.value = response;
  }

  Future<void> fetchApplicants() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch applications with Worker Details
      final response = await _supabase
          .from('order_applications')
          .select('*, worker:users(*)')
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      final List<dynamic> data = response;
      applicants.value = data.cast<Map<String, dynamic>>();
    } catch (e) {
      print('[EmployerActivityDetail] Error: $e');
      errorMessage.value = 'Gagal memuat pelamar';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String applicationId, String newStatus) async {
    try {
      await _supabase
          .from('order_applications')
          .update({'status': newStatus}).eq('id', applicationId);

      // Refresh
      fetchApplicants();
      _fetchOrderDetails(); // Update queue count

      Get.snackbar('Sukses',
          'Status pelamar diperbarui menjadi ${newStatus == 'accepted' ? 'Diterima' : 'Ditolak'}');
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status');
    }
  }

  void openWhatsApp(String phone, String jobTitle) async {
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Nomor telepon tidak tersedia');
      return;
    }

    // Format phone if needed (remove 0, add 62, etc. - assume backend stores sanitized or use simple logic)
    String formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '62${phone.substring(1)}';
    }

    final message = 'Halo, saya dari KerjoCurup terkait pekerjaan $jobTitle.';
    final url =
        'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';

    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
    }
  }
}
