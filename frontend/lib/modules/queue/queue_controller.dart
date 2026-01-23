import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../models/order_model.dart';
import '../../core/api/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class QueueController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final box = GetStorage();

  String orderId = '';
  // Added to store order details for header
  final Rx<OrderModel?> order = Rx<OrderModel?>(null);
  var queueList = <dynamic>[].obs;
  var isLoading = true.obs;
  var joinLoading = false.obs;

  // Computed properties
  String get userId => box.read('user')?['id'] ?? '';
  String get userRole => box.read('user')?['role'] ?? '';
  bool get isWorker => userRole == 'worker';

  int get myPosition {
    final index = queueList.indexWhere(
        (item) => (item['worker_id'] ?? item['worker']?['id']) == userId);
    return index != -1 ? index + 1 : 0;
  }

  bool get isJoined => myPosition > 0;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is OrderModel) {
      order.value = args;
      orderId = args.id ?? '';
    } else if (args is String) {
      orderId = args;
      fetchOrderDetails();
    }

    if (orderId.isNotEmpty) {
      fetchQueue();
    }
  }

  Future<void> fetchOrderDetails() async {
    try {
      final response = await _apiClient.dio.get('/orders/$orderId');
      if (response.statusCode == 200) {
        order.value = OrderModel.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Fetch Order Error: $e');
    }
  }

  Future<void> fetchQueue() async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.get('/orders/$orderId/queue');
      if (response.statusCode == 200) {
        queueList.value = response.data['data'];
      }
    } catch (e) {
      print('Fetch Queue Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinQueue() async {
    if (isJoined) return;

    try {
      joinLoading.value = true;
      // Backend: POST /orders/:id/queue
      final response = await _apiClient.dio.post('/orders/$orderId/queue');

      if (response.statusCode == 201) {
        Get.snackbar('Sukses', 'Anda berhasil mengambil order ini!');
        fetchQueue();
      }
      Get.snackbar('Gagal', 'Gagal mengambil order. Mungkin sudah penuh.');
    } finally {
      joinLoading.value = false;
    }
  }

  Future<void> acceptApplicant(String workerId) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.dio.post(
        '/orders/$orderId/applications/$workerId/accept',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Sukses', 'Pelamar berhasil diterima');
        fetchQueue(); // Refresh list
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menerima pelamar');
      print('Accept Error: $e');
    } finally {
      isLoading.value = false;
    }
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
