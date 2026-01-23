import 'package:get/get.dart';
import '../../core/api/api_client.dart';
import '../../models/order_model.dart';
import 'package:get_storage/get_storage.dart';

class OrdersController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();

  var orders = <OrderModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      // Prompt said GET /orders/open, but backend implementation at GET /orders defaults to open.
      // I'll try /orders first. If specific endpoint /open serves purpose later, we can adjust.
      // My backend implementation: OrdersController @Get() -> service.getOrders().
      final response = await _apiClient.dio.get('/orders');

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        orders.value = data.map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat lowongan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrder(String title, String description, int count) async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final user = box.read('user') ?? {};
      final role = user['role']; // petani / warehouse

      // Default logic for workerType based on role (Hypothesis: Petani->Pekerja, Warehouse->Ojek)
      // Or just default to 'pekerja' if unknown.
      String workerType = 'pekerja';
      if (role == 'warehouse') workerType = 'ojek';

      // Backend expects: workerType, workerCount, description, location, jobDate
      // We map Title -> part of description or ignore? Prompt says Input Judul.
      // We will prepend Title to Description: "TITLE: ...desc..."
      final fullDesc = "$title\n$description";

      final response = await _apiClient.dio.post('/orders', data: {
        'workerType': workerType,
        'workerCount': count,
        'description': fullDesc,
        'location':
            user['location'] ?? 'Lokasi Saya', // Default to user location
        'jobDate': DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String(), // Default tomorrow
      });

      if (response.statusCode == 201) {
        Get.back(); // Close page
        fetchOrders(); // Refresh list
        Get.snackbar('Sukses', 'Lowongan berhasil dibuat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat lowongan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  /// New method with full details from updated form
  Future<void> createOrderWithDetails({
    required String title,
    required String description,
    required String location,
    required int workerCount,
    required String workerType,
  }) async {
    try {
      isLoading.value = true;

      final fullDesc = "$title\n$description";

      final response = await _apiClient.dio.post('/orders', data: {
        'workerType': workerType,
        'workerCount': workerCount,
        'description': fullDesc,
        'location': location,
        'jobDate':
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      });

      if (response.statusCode == 201) {
        Get.back();
        fetchOrders();
        Get.snackbar('Sukses', 'Lowongan berhasil dibuat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuat lowongan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
