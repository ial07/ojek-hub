import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/api/api_client.dart';
import '../../../../models/order_model.dart';

class HomeEmployerController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final box = GetStorage();

  // State flags
  var isLoading = false.obs;
  var isReady = false.obs;

  // Nullable model
  var myOrders = <OrderModel>[].obs;
  var user = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    print('[HOME_EMPLOYER] Initializing...');

    // Check session first
    final session = _supabase.auth.currentSession;
    if (session == null) {
      print('[HOME_EMPLOYER] No session, cannot initialize');
      errorMessage.value = 'Sesi tidak valid';
      return;
    }

    // Load user from storage
    user.value = box.read('user');
    print('[HOME_EMPLOYER] User loaded: ${user.value?['email']}');

    // Fetch orders
    await fetchMyOrders();

    // Mark as ready
    isReady.value = true;
    print('[HOME_EMPLOYER] Ready');
  }

  Future<void> fetchMyOrders() async {
    if (isLoading.value) {
      print('[HOME_EMPLOYER] Already loading, skipping');
      return;
    }

    try {
      isLoading.value = true;
      print('[HOME_EMPLOYER] Fetching orders...');

      final response = await _apiClient.dio.get('/orders/my');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List data = response.data['data'];
        myOrders.value = data.map((e) => OrderModel.fromJson(e)).toList();
        print('[HOME_EMPLOYER] Loaded ${myOrders.length} orders');
      }
    } catch (e) {
      print('[HOME_EMPLOYER] Fetch error: $e');
      errorMessage.value = 'Gagal memuat lowongan';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    if (!isReady.value) {
      print('[HOME_EMPLOYER] Not ready, blocking refresh');
      return;
    }
    await fetchMyOrders();
  }

  /// Check if user can create orders
  bool get canCreateOrder {
    final role = user.value?['role'];
    return role == 'farmer' || role == 'warehouse';
  }
}
